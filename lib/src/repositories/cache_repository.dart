import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcf_messaging/constants.dart';
import 'package:fcf_messaging/src/models/chat_model.dart';
import 'package:fcf_messaging/src/models/chat_with_last_message_model.dart';
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
    List<RegisteredUserModel> members,
    String name,
    String photoUrl,
  });
  Stream<List<ChatWithLastMessageModel>> readChats(String uid);
}

abstract class CacheRepositoryContactsInterface {
  Future<void> addContact(UserModel contact);
  Stream<List<UserModel>> readContacts();
}

class CacheRepository
    implements
        CacheRepositoryChatsInterface,
        CacheRepositoryContactsInterface,
        MessagesRepositoryInterface {
  CacheRepository(
      {@required RegisteredUserModel authenticatedUser,
      int maxChats = MAX_CHATS,
      int maxContacts = MAX_CONTACTS})
      : assert(authenticatedUser != null),
        _authenticatedUser = authenticatedUser,
        _maxChats = maxChats,
        _maxContacts = maxContacts;

  final RegisteredUserModel _authenticatedUser;
  final int _maxChats, _maxContacts;

  final ChatsRepositoryInterface _chatsRepository = locator<ChatsRepositoryInterface>();
  final ContactsRepositoryInterface _contactsRepository =
      locator<ContactsRepositoryInterface>();
  final MessagesRepositoryInterface _messagesRepository =
      locator<MessagesRepositoryInterface>();
  final HiveRepository _hiveRepository = locator<HiveRepository>();

  final Map<String, ChatWithLastMessageModel> _chatsCache =
      <String, ChatWithLastMessageModel>{};

  final SplayTreeSet<UserModel> _contactsCache = SplayTreeSet<UserModel>(
    (UserModel a, UserModel b) => a.name.compareTo(b.name),
  );

  StreamSubscription<List<ChatModel>> _firestoreChatsSub;
  StreamSubscription<List<RegisteredUserModel>> _firestoreRegisteredUsersSub;

  final BehaviorSubject<List<ChatWithLastMessageModel>> _chatsController =
      BehaviorSubject<List<ChatWithLastMessageModel>>.seeded(
    <ChatWithLastMessageModel>[],
  );
  Sink<List<ChatWithLastMessageModel>> get _inChats => _chatsController.sink;
  Stream<List<ChatWithLastMessageModel>> get _outChats => _chatsController.stream;

  final BehaviorSubject<List<UserModel>> _contactsController =
      BehaviorSubject<List<UserModel>>.seeded(<UserModel>[]);
  Sink<List<UserModel>> get _inContacts => _contactsController.sink;
  Stream<List<UserModel>> get _outContacts => _contactsController.stream;

  Future<CacheRepository> init() async {
    final List<ChatModel> chats = await _hiveRepository.readChats();
    for (final ChatModel chat in chats) {
      final MessageModel message = await _hiveRepository.readLastMessage(chat.documentID);
      _chatsCache[chat.documentID] = ChatWithLastMessageModel(
        chat: chat,
        lastMessage: message,
      );
      chat.members.forEach(_doAddContact);
    }
    _inChats.add(_chatsCache.values.toList());

    _firestoreChatsSub = _chatsRepository.readChats(_authenticatedUser.userID).listen(
      (List<ChatModel> chats) {
        // TODO(cbonello): handle chats deleted on server side.
        addAllChats(chats);
      },
    );

    final List<UserModel> contacts = await _hiveRepository.readUsers();
    contacts.forEach(_doAddContact);

    _firestoreRegisteredUsersSub =
        _contactsRepository.readContacts(_authenticatedUser.userID).listen(
              (List<RegisteredUserModel> contacts) => addAllContacts(contacts),
            );

    return this;
  }

  // CacheRepositoryChatsInterface

  @override
  Future<void> addChat({
    List<RegisteredUserModel> members,
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
    if (cacheUpdated) {
      _inChats.add(_chatsCache.values.toList());
    }
  }

  Future<int> clearChats() async {
    _chatsCache.clear();
    return await _hiveRepository.clearChats();
  }

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
  Future<void> addContact(UserModel contact) async {
    if (contact is UnregisteredUserModel) {
      await _hiveRepository.addUser(contact);
    }
    await _doAddContact(
      contact,
      () => _inContacts.add(
        List<UserModel>.from(_contactsCache, growable: false),
      ),
    );
  }

  @override
  Stream<List<UserModel>> readContacts() => _outContacts;

  Future<void> addAllContacts(Iterable<UserModel> contacts) async {
    bool cacheUpdated = false;
    for (final UserModel contact in contacts) {
      await _doAddContact(contact, () => cacheUpdated = true);
    }
    if (cacheUpdated) {
      _inContacts.add(List<UserModel>.from(_contactsCache, growable: false));
    }
  }

  Future<int> clearContacts() async {
    _contactsCache.clear();
    return await _hiveRepository.clearUsers();
  }

  Future<void> _doAddContact(UserModel contact, [Function addHandler]) async {
    final UserModel cachedContact = await _hiveRepository.readUser(contact.email);
    if (cachedContact == null) {
      if (_contactsCache.length >= _maxContacts - 1) {
        throw const AppException('Too many contacts');
      }
      await _hiveRepository.addUser(contact);
      if (addHandler != null) {
        addHandler();
      }
    } else {
      await _hiveRepository.updateUser(contact);
      if (addHandler != null) {
        addHandler();
      }
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
  Future<void> sendTextMessage(
      String chatId, RegisteredUserModel sender, String text) async {
    final TextMessageModel message = TextMessageModel(
      documentID: null,
      sender: sender.userID,
      text: text,
      timestamp: Timestamp.now(),
    );
    await _hiveRepository.saveLastMessage(chatId, message);
    await _messagesRepository.sendTextMessage(chatId, sender, text);
  }

  @override
  Future<void> sendImageMessage(
      String chatId, RegisteredUserModel sender, File imageFile) async {
    final ImageMessageModel message = ImageMessageModel(
      documentID: null,
      sender: sender.userID,
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
    await _firestoreRegisteredUsersSub?.cancel();
    await _firestoreChatsSub?.cancel();
    await _chatsController.close();
  }
}
