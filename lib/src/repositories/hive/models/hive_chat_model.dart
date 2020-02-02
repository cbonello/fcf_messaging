import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcf_messaging/src/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'hive_chat_model.g.dart';

@HiveType(typeId: 0)
class HiveChatModel extends HiveObject {
  HiveChatModel({
    @required this.documentID,
    @required this.private,
    @required this.members,
    this.name,
    this.photoUrl,
    @required this.createdAt,
  });

  factory HiveChatModel.fromChatModel(ChatModel chat) {
    return HiveChatModel(
      documentID: chat.documentID,
      private: chat.private,
      members: chat.members
          .map<HiveChatMemberModel>(
            (ChatMember cmd) => HiveChatMemberModel.fromChatMember(cmd),
          )
          .toList(),
      name: chat.name,
      photoUrl: chat.photoUrl,
      createdAt: chat.createdAt.toDate().toString(),
    );
  }

  ChatModel toChatModel() {
    final List<ChatMember> chatMembers =
        members.map((HiveChatMemberModel ldcmd) => ldcmd.toChatMember()).toList();
    chatMembers.sort(
      (ChatMember m1, ChatMember m2) => m1.userID.compareTo(m2.userID),
    );

    return ChatModel(
      documentID: documentID,
      private: private,
      members: chatMembers,
      name: name,
      photoUrl: photoUrl,
      createdAt: Timestamp.fromDate(DateTime.parse(createdAt)),
    );
  }

  @HiveField(0)
  final String documentID;

  @HiveField(1)
  final bool private;

  @HiveField(2)
  final List<HiveChatMemberModel> members;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final String photoUrl;

  @HiveField(5)
  final String createdAt;

  @override
  String toString() {
    return '''HiveChatModel {
      documentID: "$documentID",
      private,: $private,
      members: [ $members ],
      name: "$name",
      photoUrl: "$photoUrl",
      createdAt: "$createdAt",
    }''';
  }
}

@HiveType(typeId: 1)
class HiveChatMemberModel extends HiveObject {
  HiveChatMemberModel({
    @required this.userID,
    @required this.name,
    this.photoUrl,
    @required this.status,
  });

  factory HiveChatMemberModel.fromChatMember(ChatMember cmd) {
    return HiveChatMemberModel(
      userID: cmd.userID,
      name: cmd.name,
      photoUrl: cmd.photoUrl,
      status: cmd.status,
    );
  }

  ChatMember toChatMember() => ChatMember(
        userID: userID,
        name: name,
        photoUrl: photoUrl,
        status: status,
      );

  @HiveField(0)
  final String userID;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String photoUrl;

  @HiveField(3)
  final String status;

  @override
  String toString() {
    return '''HiveChatMemberModel {
      userID: "$userID",
      name: "$name",
      photoUrl: "#$photoUrl",
      status: "$status",
    }''';
  }
}
