import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcf_messaging/constants.dart';
import 'package:meta/meta.dart';

abstract class MessageModel {
  const MessageModel({
    @required this.documentID,
    @required this.sender,
    @required this.timestamp,
  })  : assert(documentID != null),
        assert(sender != null),
        assert(timestamp != null);

  factory MessageModel.fromJson(String documentID, Map<String, dynamic> data) {
    final int type = data['type'] ?? MESSAGE_TEXT_TYPE;
    assert(<int>[MESSAGE_TEXT_TYPE, MESSAGE_IMAGE_TYPE].contains(type));

    if (type == MESSAGE_TEXT_TYPE) {
      return TextMessageModel.fromJson(documentID, data);
    }
    return ImageMessageModel.fromJson(documentID, data);
  }

  Map<String, dynamic> toMap();

  final String documentID, sender;
  final Timestamp timestamp;
}

class TextMessageModel extends MessageModel {
  TextMessageModel({
    @required String documentID,
    @required String sender,
    @required this.text,
    @required Timestamp timestamp,
  }) : super(documentID: documentID, sender: sender, timestamp: timestamp);

  factory TextMessageModel.fromJson(String documentID, Map<String, dynamic> data) {
    assert(documentID != null);
    return TextMessageModel(
      documentID: documentID,
      sender: data['sender'],
      text: data['text'],
      timestamp: data['timestamp'],
    );
  }

  String text;

  int get type => MESSAGE_TEXT_TYPE;

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'sender': sender,
      'type': type,
      'text': text,
      'timestamp': timestamp,
    };
    return map;
  }

  @override
  String toString() => '''TextMessageModel {
      documentID: $documentID,
      sender: $sender,
      text: $text,
      timestamp: "$timestamp"
    }''';
}

class ImageMessageModel extends MessageModel {
  ImageMessageModel({
    @required String documentID,
    @required String sender,
    @required this.imageUrl,
    @required Timestamp timestamp,
  })  : assert(imageUrl != null),
        super(documentID: documentID, sender: sender, timestamp: timestamp);

  factory ImageMessageModel.fromJson(String documentID, Map<String, dynamic> data) {
    assert(documentID != null);
    return ImageMessageModel(
      documentID: documentID,
      sender: data['sender'],
      imageUrl: data['imageUrl'],
      timestamp: data['timestamp'],
    );
  }

  String imageUrl;

  int get type => MESSAGE_IMAGE_TYPE;

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'sender': sender,
      'type': type,
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
    return map;
  }

  @override
  String toString() => '''ImageMessageModel {
      documentID: $documentID,
      sender: $sender,
      imageUrl: "$imageUrl",
      timestamp: "$timestamp"
    }''';
}
