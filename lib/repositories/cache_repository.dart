import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcf_messaging/constants.dart';
import 'package:fcf_messaging/locator.dart';
import 'package:fcf_messaging/models/chat_model.dart';
import 'package:fcf_messaging/models/chat_with_last_message_model.dart';
import 'package:fcf_messaging/models/contact_model.dart';
import 'package:fcf_messaging/models/message_model.dart';
import 'package:fcf_messaging/models/user_model.dart';
import 'package:fcf_messaging/repositories/firestore_repository.dart';
import 'package:fcf_messaging/repositories/hive/hive_repository.dart';
import 'package:fcf_messaging/utils/exceptions.dart';
import 'package:rxdart/rxdart.dart';

abstract class ICacheRepositoryChats {
  Future<void> addChat(ChatModel chat);
  Stream<List<ChatWithLastMessageModel>> readChats(String uid);
}

abstract class ICacheRepositoryContacts {
  Future<void> addContact(ContactModel contact);
  Stream<List<ContactModel>> readContacts(String uid);
}

class CacheRepository
    implements
        ICacheRepositoryChats,
        ICacheRepositoryContacts,
        IFirestoreRepositoryMessages {
  CacheRepository({int maxChats = MAX_CHATS, int maxContacts = MAX_CONTACTS})
      : _maxChats = maxChats,
        _maxContacts = maxContacts;

  final int _maxChats, _maxContacts;

  final FirestoreRepository _firestoreRepository = locator<FirestoreRepository>();
  final HiveRepository _hiveRepository = locator<HiveRepository>();

  final Map<String, ChatWithLastMessageModel> _chatsCache =
      <String, ChatWithLastMessageModel>{};
  final SplayTreeSet<ContactModel> _contactsCache = SplayTreeSet<ContactModel>(
    (ContactModel a, ContactModel b) => a.name.compareTo(b.name),
  );

  StreamSubscription<List<ChatModel>> _firestoreChatsSub;
  StreamSubscription<List<ContactModel>> _firestoreContactsSub;

  final BehaviorSubject<List<ChatWithLastMessageModel>> _chatsController =
      BehaviorSubject<List<ChatWithLastMessageModel>>.seeded(
          <ChatWithLastMessageModel>[]);
  Sink<List<ChatWithLastMessageModel>> get _inChats => _chatsController.sink;
  Stream<List<ChatWithLastMessageModel>> get _outChats => _chatsController.stream;
  final BehaviorSubject<List<ContactModel>> _contactsController =
      BehaviorSubject<List<ContactModel>>.seeded(<ContactModel>[]);
  Sink<List<ContactModel>> get _inContacts => _contactsController.sink;
  Stream<List<ContactModel>> get _outContacts => _contactsController.stream;

  Future<CacheRepository> init() async {
    final List<ChatModel> chats = await _hiveRepository.readChats();
    for (final ChatModel chat in chats) {
      final MessageModel message = await _hiveRepository.readLastMessage(chat.documentID);
      _chatsCache[chat.documentID] = ChatWithLastMessageModel(
        chat: chat,
        lastMessage: message,
      );
    }
    final List<ContactModel> contacts = await _hiveRepository.readContacts();
    contacts.forEach(_contactsCache.add);
    return this;
  }

  // IFirestoreRepositoryChats

  @override
  Future<void> addChat(ChatModel chat) async {
    await _doAddChat(chat, () => _inChats.add(_chatsCache.values));
  }

  @override
  Stream<List<ChatWithLastMessageModel>> readChats(String uid) {
    _firestoreChatsSub?.cancel();
    _firestoreChatsSub = _firestoreRepository
        .readChats(uid)
        .listen((List<ChatModel> chats) => addAllChats(chats));
    return _outChats;
  }

  Future<void> addAllChats(Iterable<ChatModel> chats) async {
    bool cacheUpdated = false;
    for (final ChatModel chat in chats) {
      await _doAddChat(chat, () => cacheUpdated = true);
    }
    if (cacheUpdated) {
      _inChats.add(_chatsCache.values);
    }
  }

  Future<int> clearChats() async {
    _chatsCache.clear();
    return await _hiveRepository.clearChats();
  }

  bool _chatExists(ChatModel chat) {
    return _chatsCache.containsValue(chat);
  }

  Future<void> _doAddChat(ChatModel chat, Function addHandler) async {
    if (_chatExists(chat) == false) {
      if (_chatsCache.length >= _maxChats - 1) {
        throw const AppException('Too many chats');
      }
      await _hiveRepository.addChat(chat);
      final MessageModel lastMessage =
          await _hiveRepository.readLastMessage(chat.documentID);
      _chatsCache[chat.documentID] = ChatWithLastMessageModel(
        chat: chat,
        lastMessage: lastMessage,
      );
      addHandler();
    }
  }

  // ICacheRepositoryContacts

  @override
  Future<void> addContact(ContactModel contact) async {
    await _doAddContact(
      contact,
      () => _inContacts.add(
        List<ContactModel>.from(
          _contactsCache,
          growable: false,
        ),
      ),
    );
  }

  @override
  Stream<List<ContactModel>> readContacts(String uid) {
    _firestoreContactsSub?.cancel();
    _firestoreContactsSub = _firestoreRepository
        .readContacts(uid)
        .listen((List<ContactModel> contacts) => addAllContacts(contacts));
    return _outContacts;
  }

  Future<void> addAllContacts(Iterable<ContactModel> contacts) async {
    bool cacheUpdated = false;
    for (final ContactModel contact in contacts) {
      await _doAddContact(contact, () => cacheUpdated = true);
    }
    if (cacheUpdated) {
      _inContacts.add(List<ContactModel>.from(_contactsCache, growable: false));
    }
  }

  Future<int> clearContacts() async {
    _contactsCache.clear();
    return await _hiveRepository.clearContacts();
  }

  bool _contactExists(ContactModel contact) {
    return _contactsCache.contains(contact);
  }

  Future<void> _doAddContact(ContactModel contact, Function addHandler) async {
    if (_contactExists(contact) == false) {
      if (_contactsCache.length >= _maxContacts - 1) {
        throw const AppException('Too many contacts');
      }
      await _hiveRepository.addContact(contact);
      addHandler();
    }
  }

  // IFirestoreRepositoryMessages

  @override
  Stream<List<MessageModel>> getFirstChatMessages(String chatId) {
    return _firestoreRepository.getFirstChatMessages(chatId).doOnData(
      (List<MessageModel> chats) async {
        await _hiveRepository.saveLastMessage(chatId, chats[0]);
      },
    );
  }

  @override
  Future<List<MessageModel>> getPreviousChatMessages(
    String chatId,
    MessageModel prevMessage,
  ) =>
      _firestoreRepository.getPreviousChatMessages(chatId, prevMessage);

  @override
  Future<void> sendTextMessage(String chatId, UserModel sender, String text) async {
    final TextMessageModel message = TextMessageModel(
      documentID: null,
      sender: sender.documentID,
      text: text,
      timestamp: Timestamp.now(),
    );
    await _hiveRepository.saveLastMessage(chatId, message);
    await _firestoreRepository.sendTextMessage(chatId, sender, text);
  }

  @override
  Future<void> sendImageMessage(String chatId, UserModel sender, File imageFile) async {
    final ImageMessageModel message = ImageMessageModel(
      documentID: null,
      sender: sender.documentID,
      imageUrl: null,
      timestamp: Timestamp.now(),
    );
    await _hiveRepository.saveLastMessage(chatId, message);
    await _firestoreRepository.sendImageMessage(chatId, sender, imageFile);
  }

  @override
  Future<List<ImageMessageModel>> getImageAttachments(String chatId) =>
      _firestoreRepository.getImageAttachments(chatId);

  Future<void> dispose() async {
    await _firestoreContactsSub.cancel();
    await _firestoreChatsSub?.cancel();
    await _chatsController.close();
  }
}
