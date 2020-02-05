import 'dart:async';
import 'dart:io';

import 'package:fcf_messaging/src/models/chat_model.dart';
import 'package:fcf_messaging/src/models/message_model.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/repositories/hive/models/hive_chat_model.dart';
import 'package:fcf_messaging/src/repositories/hive/models/hive_message_model.dart';
import 'package:fcf_messaging/src/repositories/hive/models/hive_registered_user_model.dart';
import 'package:fcf_messaging/src/repositories/hive/models/hive_unregistered_user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

abstract class IHiveRepositoryChats {
  Future<void> addChat(ChatModel chat);
  Future<void> addChats(Iterable<ChatModel> chats);
  Future<ChatModel> readChat(String chatID);
  Future<List<ChatModel>> readChats();
  Future<void> updateChat(ChatModel chat);
  Future<int> clearChats();
}

abstract class IHiveRepositoryUnregisteredUsers {
  Future<void> addUnregisteredUser(UnregisteredUserModel unregisteredUser);
  Future<void> addUnregisteredUsers(List<UnregisteredUserModel> unregisteredUsers);
  Future<List<UnregisteredUserModel>> readUnregisteredUsers();
  Future<int> clearUnregisteredUsers();
}

abstract class IHiveRepositoryLastMessages {
  Future<void> saveLastMessage(String chatID, MessageModel message);
  Future<MessageModel> readLastMessage(String chatID);
  Future<void> clearMessages();
}

class HiveRepository
    implements
        IHiveRepositoryChats,
        IHiveRepositoryUnregisteredUsers,
        IHiveRepositoryLastMessages {
  HiveRepository({@required Directory documentDir}) : _documentDir = documentDir {
    if (!kIsWeb) {
      Hive.init(_documentDir.path);
    }
    Hive.registerAdapter(HiveChatModelAdapter());
    Hive.registerAdapter(HiveMessageModelAdapter());
    Hive.registerAdapter(HiveRegisteredUserModelAdapter());
    Hive.registerAdapter(HiveUnregisteredUserModelAdapter());
  }

  final Directory _documentDir;
  LazyBox<HiveChatModel> _chatsBox;
  LazyBox<HiveUnregisteredUserModel> _unregisteredUsersBox;
  LazyBox<HiveMessageModel> _messagesBox;

  Future<void> openBoxes() async {
    _chatsBox = await Hive.openLazyBox<HiveChatModel>('chats');
    await _chatsBox.clear();
    _unregisteredUsersBox =
        await Hive.openLazyBox<HiveUnregisteredUserModel>('unregistered_users');
    await _unregisteredUsersBox.clear();
    _messagesBox = await Hive.openLazyBox<HiveMessageModel>('messages');
    await _messagesBox.clear();
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
  Future<ChatModel> readChat(String chatID) async {
    assert(_chatsBox.isOpen);
    final HiveChatModel hiveChat = await _chatsBox.get(chatID);
    final ChatModel chat = hiveChat?.toChatModel();
    return chat;
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
  Future<void> updateChat(ChatModel chat) async {
    final String key = chat.documentID;
    await _chatsBox.delete(key);
    final HiveChatModel hiveChat = HiveChatModel.fromChatModel(chat);
    await _chatsBox.put(key, hiveChat);
  }

  @override
  Future<int> clearChats() async {
    assert(_chatsBox.isOpen);
    return await _chatsBox.clear();
  }

  // IHiveRepositoryContacts

  @override
  Future<void> addUnregisteredUser(UnregisteredUserModel unregisteredUser) async {
    assert(_unregisteredUsersBox.isOpen);
    final HiveUnregisteredUserModel hiveUnregisteredUser =
        HiveUnregisteredUserModel.fromUnregisteredUserModel(unregisteredUser);
    await _unregisteredUsersBox.put(hiveUnregisteredUser.hashCode, hiveUnregisteredUser);
  }

  @override
  Future<void> addUnregisteredUsers(List<UnregisteredUserModel> unregisteredUsers) async {
    await clearUnregisteredUsers();
    unregisteredUsers.forEach(addUnregisteredUser);
  }

  @override
  Future<List<UnregisteredUserModel>> readUnregisteredUsers() async {
    assert(_unregisteredUsersBox.isOpen);
    final List<UnregisteredUserModel> unregisteredUsers = <UnregisteredUserModel>[];
    for (int i = 0; i < _unregisteredUsersBox.length; i++) {
      final HiveUnregisteredUserModel hiveContact = await _unregisteredUsersBox.getAt(i);
      final UnregisteredUserModel contact = hiveContact.toUnregisteredUserModel();
      unregisteredUsers.add(contact);
    }
    return unregisteredUsers;
  }

  @override
  Future<int> clearUnregisteredUsers() async {
    assert(_unregisteredUsersBox.isOpen);
    return await _unregisteredUsersBox.clear();
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
    await _messagesBox.compact();
    await _unregisteredUsersBox.compact();
    await _chatsBox.compact();
    await Hive.close();
  }
}
