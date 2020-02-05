import 'dart:async';
import 'dart:io';

import 'package:fcf_messaging/src/models/chat_model.dart';
import 'package:fcf_messaging/src/models/message_model.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/repositories/hive/models/hive_chat_model.dart';
import 'package:fcf_messaging/src/repositories/hive/models/hive_message_model.dart';
import 'package:fcf_messaging/src/repositories/hive/models/hive_user_model.dart';
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

abstract class IHiveRepositoryUsers {
  Future<void> addUser(UserModel user);
  Future<void> addUsers(List<UserModel> users);
  Future<UserModel> readUser(String email);
  Future<List<UserModel>> readUsers();
  Future<void> updateUser(UserModel user);
  Future<int> clearUsers();
}

abstract class IHiveRepositoryLastMessages {
  Future<void> saveLastMessage(String chatID, MessageModel message);
  Future<MessageModel> readLastMessage(String chatID);
  Future<void> clearMessages();
}

class HiveRepository
    implements IHiveRepositoryChats, IHiveRepositoryUsers, IHiveRepositoryLastMessages {
  HiveRepository({@required Directory documentDir}) : _documentDir = documentDir {
    if (!kIsWeb) {
      Hive.init(_documentDir.path);
    }
    Hive.registerAdapter(HiveChatModelAdapter());
    Hive.registerAdapter(HiveMessageModelAdapter());
    Hive.registerAdapter(HiveUserModelAdapter());
  }

  final Directory _documentDir;
  LazyBox<HiveChatModel> _chatsBox;
  LazyBox<HiveUserModel> _usersBox;
  LazyBox<HiveMessageModel> _messagesBox;

  Future<void> openBoxes() async {
    _chatsBox = await Hive.openLazyBox<HiveChatModel>('chats');
    await _chatsBox.clear();

    _usersBox = await Hive.openLazyBox<HiveUserModel>('users');
    await _usersBox.clear();

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
    assert(_chatsBox.isOpen);
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
  Future<void> addUser(UserModel user) async {
    assert(_usersBox.isOpen);
    final String key = user.email;
    if (_usersBox.containsKey(key)) {
      await _usersBox.delete(key);
    }
    final HiveUserModel hiveUser = HiveUserModel.fromUserModel(user);
    await _usersBox.put(key, hiveUser);
  }

  @override
  Future<void> addUsers(List<UserModel> users) async {
    await clearUsers();
    users.forEach(addUser);
  }

  @override
  Future<UserModel> readUser(String email) async {
    assert(_usersBox.isOpen);
    final HiveUserModel hiveUser = await _usersBox.get(email);
    final UserModel user = hiveUser?.toUserModel();
    return user;
  }

  @override
  Future<List<UserModel>> readUsers() async {
    assert(_usersBox.isOpen);
    final List<UserModel> users = <UserModel>[];
    for (int i = 0; i < _usersBox.length; i++) {
      final HiveUserModel hiveUser = await _usersBox.getAt(i);
      final UserModel user = hiveUser.toUserModel();
      users.add(user);
    }
    return users;
  }

  @override
  Future<void> updateUser(UserModel user) async {
    assert(_usersBox.isOpen);
    final String key = user.email;
    await _usersBox.delete(key);
    final HiveUserModel hiveUser = HiveUserModel.fromUserModel(user);
    await _usersBox.put(key, hiveUser);
  }

  @override
  Future<int> clearUsers() async {
    assert(_usersBox.isOpen);
    return await _usersBox.clear();
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
    await _usersBox.compact();
    await _chatsBox.compact();
    await Hive.close();
  }
}
