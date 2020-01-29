import 'dart:async';
import 'dart:io';

import 'package:fcf_messaging/models/chat_model.dart';
import 'package:fcf_messaging/models/contact_model.dart';
import 'package:fcf_messaging/models/message_model.dart';
import 'package:fcf_messaging/repositories/hive/models/hive_chat_model.dart';
import 'package:fcf_messaging/repositories/hive/models/hive_contact_model.dart';
import 'package:fcf_messaging/repositories/hive/models/hive_message_model.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

abstract class IHiveRepositoryChats {
  Future<void> addChat(ChatModel chat);
  Future<void> addChats(Iterable<ChatModel> chats);
  Future<List<ChatModel>> readChats();
  Future<int> clearChats();
}

abstract class IHiveRepositoryContacts {
  Future<void> addContact(ContactModel contact);
  Future<void> addContacts(List<ContactModel> contacts);
  Future<List<ContactModel>> readContacts();
  Future<int> clearContacts();
}

abstract class IHiveRepositoryLastMessages {
  Future<void> saveLastMessage(String chatID, MessageModel message);
  Future<MessageModel> readLastMessage(String chatID);
  Future<void> clearMessages();
}

class HiveRepository
    implements
        IHiveRepositoryChats,
        IHiveRepositoryContacts,
        IHiveRepositoryLastMessages {
  HiveRepository({@required Directory documentDir}) : _documentDir = documentDir {
    Hive.init(_documentDir.path);
    Hive.registerAdapter(HiveChatModelAdapter());
    Hive.registerAdapter(HiveChatMemberModelAdapter());
    Hive.registerAdapter(HiveContactModelAdapter());
    Hive.registerAdapter(HiveMessageModelAdapter());
  }

  final Directory _documentDir;
  LazyBox<HiveChatModel> _chatsBox;
  LazyBox<HiveContactModel> _contactsBox;
  LazyBox<HiveMessageModel> _messagesBox;

  Future<void> openBoxes() async {
    _chatsBox = await Hive.openLazyBox<HiveChatModel>('chats');
    _contactsBox = await Hive.openLazyBox<HiveContactModel>('contacts');
    _messagesBox = await Hive.openLazyBox<HiveMessageModel>('messages');
  }

  // IHiveRepositoryChats

  @override
  Future<void> addChat(ChatModel chat) async {
    assert(_chatsBox.isOpen);
    final String key = chat.documentID;
    if (_chatsBox.containsKey(key)) {
      await _chatsBox.delete(key);
    }
    final HiveChatModel hiveChat = HiveChatModel.fromChatModel(chat);
    await _chatsBox.put(key, hiveChat);
  }

  @override
  Future<void> addChats(Iterable<ChatModel> chats) async {
    await clearChats();
    chats.forEach(addChat);
  }

  @override
  Future<List<ChatModel>> readChats() async {
    assert(_chatsBox.isOpen);
    final List<ChatModel> chats = <ChatModel>[];
    for (int i = 0; i < _chatsBox.length; i++) {
      final HiveChatModel hiveChat = await _chatsBox.getAt(i);
      final ChatModel chat = hiveChat.toChatModel();
      chats.add(chat);
    }
    return chats;
  }

  @override
  Future<int> clearChats() async {
    assert(_chatsBox.isOpen);
    return await _chatsBox.clear();
  }

  // IHiveRepositoryContacts

  @override
  Future<void> addContact(ContactModel contact) async {
    assert(_contactsBox.isOpen);
    final HiveContactModel hiveContact = HiveContactModel.fromContactModel(contact);
    await _contactsBox.put(hiveContact.hashCode, hiveContact);
  }

  @override
  Future<void> addContacts(List<ContactModel> contacts) async {
    await clearContacts();
    contacts.forEach(addContact);
  }

  @override
  Future<List<ContactModel>> readContacts() async {
    assert(_contactsBox.isOpen);
    final List<ContactModel> contacts = <ContactModel>[];
    for (int i = 0; i < _contactsBox.length; i++) {
      final HiveContactModel hiveContact = await _contactsBox.getAt(i);
      final ContactModel contact = hiveContact.toContactModel();
      contacts.add(contact);
    }
    return contacts;
  }

  @override
  Future<int> clearContacts() async {
    assert(_contactsBox.isOpen);
    return await _contactsBox.clear();
  }

  // IHiveRepositoryLastMessages

  @override
  Future<void> saveLastMessage(String chatID, MessageModel message) async {
    final HiveMessageModel hiveMessage = HiveMessageModel.fromChatMessageModel(
      message,
    );
    assert(_messagesBox.isOpen);
    await _messagesBox.delete(chatID);
    await _messagesBox.put(chatID, hiveMessage);
  }

  @override
  Future<MessageModel> readLastMessage(String chatID) async {
    assert(_messagesBox.isOpen);
    final HiveMessageModel hiveMessage = await _messagesBox.get(chatID);
    final MessageModel message = hiveMessage?.toChatMessageModel();
    return message;
  }

  @override
  Future<void> clearMessages() async {
    assert(_messagesBox.isOpen);
    await _messagesBox.clear();
  }

  Future<void> dispose() async {
    await Hive.close();
  }
}
