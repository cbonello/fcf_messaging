// Special class to save messages in local DB since hive_generator does not
// handle abstract classes.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcf_messaging/constants.dart';
import 'package:fcf_messaging/src/models/message_model.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'hive_message_model.g.dart';

@HiveType(typeId: 1)
class HiveMessageModel extends HiveObject {
  HiveMessageModel({
    @required this.documentID,
    @required this.sender,
    @required this.type,
    this.text,
    @required this.timestamp,
  });

  factory HiveMessageModel.fromChatMessageModel(MessageModel message) {
    int type;
    String text;

    if (message is TextMessageModel) {
      type = message.type;
      text = message.text;
    } else if (message is ImageMessageModel) {
      type = message.type;
      text = null;
    }

    return HiveMessageModel(
      documentID: message.documentID,
      sender: message.sender,
      type: type,
      text: text,
      timestamp: message.timestamp.toDate().toString(),
    );
  }

  MessageModel toChatMessageModel() {
    if (type == MESSAGE_TEXT_TYPE) {
      return TextMessageModel(
        documentID: documentID,
        sender: sender,
        text: text,
        timestamp: Timestamp.fromDate(DateTime.parse(timestamp)),
      );
    }

    assert(type == MESSAGE_IMAGE_TYPE);
    return ImageMessageModel(
      documentID: documentID,
      sender: sender,
      imageUrl: null,
      timestamp: Timestamp.fromDate(DateTime.parse(timestamp)),
    );
  }

  @HiveField(0)
  final String documentID;

  @HiveField(1)
  final String sender;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final int type;

  @HiveField(4)
  final String timestamp;

  @override
  String toString() {
    return '''HiveMessageModel {
      documentID: "$documentID",
      sender: "$sender", 
      text: "$text",
      type: $type,
      timestamp: $Timestamp,
    }''';
  }
}
