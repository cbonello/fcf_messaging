import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcf_messaging/src/models/chat_model.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/repositories/hive/models/hive_user_model.dart';
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
          .map<HiveUserModel>(
            (RegisteredUserModel member) => HiveUserModel.fromUserModel(member),
          )
          .toList(),
      name: chat.name,
      photoUrl: chat.photoUrl,
      createdAt: chat.createdAt.toDate().toString(),
    );
  }

  ChatModel toChatModel() {
    final List<RegisteredUserModel> chatMembers =
        members.map((HiveUserModel hiveMember) => hiveMember.toUserModel()).toList();
    chatMembers.sort(
      (RegisteredUserModel m1, RegisteredUserModel m2) => m1.userID.compareTo(m2.userID),
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
  final List<HiveUserModel> members;

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
