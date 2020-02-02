import 'package:fcf_messaging/src/models/chat_model.dart';
import 'package:fcf_messaging/src/models/message_model.dart';
import 'package:meta/meta.dart';

class ChatWithLastMessageModel {
  ChatWithLastMessageModel({
    @required this.chat,
    this.lastMessage,
  }) : assert(chat != null);

  final ChatModel chat;
  final MessageModel lastMessage;

  @override
  String toString() => '''ChatWithLastMessageModel {
      chat: { $chat },
      lastMessage: { $lastMessage }
    }''';
}
