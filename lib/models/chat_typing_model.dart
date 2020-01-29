import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class ChatTyping extends Equatable {
  const ChatTyping({@required this.documentID, @required this.timestamp})
      : assert(documentID != null),
        assert(timestamp != null);

  factory ChatTyping.fromJson(String documentID, Map<String, dynamic> json) {
    return ChatTyping(
      documentID: documentID,
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'timestamp': timestamp,
      };

  final String documentID;
  final Timestamp timestamp;

  @override
  List<Object> get props => <Object>[documentID, timestamp];

  @override
  String toString() {
    return '''ChatTyping {
      documentID: "$documentID",
      timestamp: $timestamp
    }''';
  }
}
