import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcf_messaging/constants.dart';
import 'package:fcf_messaging/src/models/chat_model.dart';
import 'package:fcf_messaging/src/models/chat_with_last_message_model.dart';
import 'package:fcf_messaging/src/models/contact_model.dart';
import 'package:fcf_messaging/src/models/message_model.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/repositories/chats_repository.dart';
import 'package:fcf_messaging/src/repositories/contacts_repository.dart';
import 'package:fcf_messaging/src/repositories/hive/hive_repository.dart';
import 'package:fcf_messaging/src/repositories/messages_repository.dart';
import 'package:fcf_messaging/src/services/service_locator.dart';
import 'package:fcf_messaging/src/utils/exceptions.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';
import 'package:rxdart/rxdart.dart';

abstract class CacheRepositoryChatsInterface {
  Future<void> addChat({
    List<ChatMember> members,
    String name,
    String photoUrl,
  });
  Stream<List<ChatWithLastMessageModel>> readChats(String uid);
}

abstract class CacheRepositoryContactsInterface {
  Future<void> addContact(ContactModel contact);
  Stream<List<ContactModel>> readContacts(String uid);
}

class CacheRepository
    implements
        CacheRepositoryChatsInterface,
        CacheRepositoryContactsInterface,
        MessagesRepositoryInterface {
  CacheRepository(
      {@required UserModel user,
      int maxChats = MAX_CHATS,
      int maxContacts = MAX_CONTACTS})
      : _user = user,
        _maxChats = maxChats,
        _maxContacts = maxContacts,
        assert(user != null);

  final UserModel _user;
  final int _maxChats, _maxContacts;

  final ChatsRepositoryInterface _chatsRepository = locator<ChatsRepositoryInterface>();
  final ContactsRepositoryInterface _contactsRepository =
      locator<ContactsRepositoryInterface>();
  final MessagesRepositoryInterface _messagesRepository =
      locator<MessagesRepositoryInterface>();
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
    <ChatWithLastMessageModel>[],
  );
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
    _inChats.add(_chatsCache.values.toList());

    final List<ContactModel> contacts = await _hiveRepository.readContacts();
    contacts.forEach(_contactsCache.add);

    _firestoreChatsSub = _chatsRepository.readChats(_user.documentID).listen(
      (List<ChatModel> chats) {
        // TODO(cbonello): handle chats deleted on server side.
        addAllChats(chats);
      },
    );

    _firestoreContactsSub = _contactsRepository
        .readContacts(_user.documentID)
        .listen((List<ContactModel> contacts) => addAllContacts(contacts));

    return this;
  }

  // CacheRepositoryChatsInterface

  @override
  Future<void> addChat({
    List<ChatMember> members,
    String name,
    String photoUrl,
  }) async {
    final ChatModel chat = ChatModel(
      documentID: _chatsRepository.generateDocumentID(),
      members: members,
      name: name,
      photoUrl: photoUrl,
      createdAt: Timestamp.now(),
    );
    await _doAddChat(chat, () {
      unawaited(_chatsRepository.addChat(chat));
      _inChats.add(_chatsCache.values.toList());
    });
  }

  @override
  Stream<List<ChatWithLastMessageModel>> readChats(String uid) => _outChats;

  Future<void> addAllChats(Iterable<ChatModel> chats) async {
    bool cacheUpdated = false;
    for (final ChatModel chat in chats) {
      await _doAddChat(chat, () => cacheUpdated = true);
    }
    print('#### cacheUpdated: $cacheUpdated');
    if (cacheUpdated) {
      _inChats.add(_chatsCache.values.toList());
    }
  }

  Future<int> clearChats() async {
    _chatsCache.clear();
    return await _hiveRepository.clearChats();
  }

  // bool _chatExists(ChatModel chat) {
  //   return _chatsCache.containsValue(chat);
  // }

  Future<void> _doAddChat(ChatModel chat, Function addHandler) async {
    final ChatModel cachedChat = await _hiveRepository.readChat(chat.documentID);
    if (cachedChat == null) {
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
    } else if (cachedChat != chat) {
      await _hiveRepository.updateChat(chat);
      final MessageModel lastMessage =
          await _hiveRepository.readLastMessage(chat.documentID);
      _chatsCache[chat.documentID] = ChatWithLastMessageModel(
        chat: chat,
        lastMessage: lastMessage,
      );
      addHandler();
    }
  }

  // CacheRepositoryContactsInterface

  @override
  Future<void> addContact(ContactModel contact) async {
    await _doAddContact(
      contact,
      () => _inContacts.add(
        List<ContactModel>.from(_contactsCache, growable: false),
      ),
    );
  }

  @override
  Stream<List<ContactModel>> readContacts(String uid) => _outContacts;

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

  // MessagesRepositoryInterface

  @override
  Stream<List<MessageModel>> getFirstChatMessages(String chatId) {
    return _messagesRepository.getFirstChatMessages(chatId).doOnData(
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
      _messagesRepository.getPreviousChatMessages(chatId, prevMessage);

  @override
  Future<void> sendTextMessage(String chatId, UserModel sender, String text) async {
    final TextMessageModel message = TextMessageModel(
      documentID: null,
      sender: sender.documentID,
      text: text,
      timestamp: Timestamp.now(),
    );
    await _hiveRepository.saveLastMessage(chatId, message);
    await _messagesRepository.sendTextMessage(chatId, sender, text);
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
    await _messagesRepository.sendImageMessage(chatId, sender, imageFile);
  }

  @override
  Future<List<ImageMessageModel>> getImageAttachments(String chatId) =>
      _messagesRepository.getImageAttachments(chatId);

  Future<void> dispose() async {
    await _firestoreContactsSub.cancel();
    await _firestoreChatsSub?.cancel();
    await _chatsController.close();
  }
}
