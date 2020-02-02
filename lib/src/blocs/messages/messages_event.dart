part of 'messages_bloc.dart';

abstract class MessagesEvent extends Equatable {
  const MessagesEvent();

  @override
  List<Object> get props => <Object>[];
}

class FetchMessagesEvent extends MessagesEvent {
  const FetchMessagesEvent(this.chatId);

  final String chatId;

  @override
  List<Object> get props => <Object>[chatId];

  @override
  String toString() => 'FetchedMessagesEvent { chat: $chatId }';
}

class ReceivedFirstMessagesEvent extends MessagesEvent {
  const ReceivedFirstMessagesEvent(this.messages);

  final List<MessageModel> messages;

  @override
  List<Object> get props => <Object>[messages];

  @override
  String toString() => 'ReceivedMessagesEvent { messages: [ $messages ] }';
}

class FetchPreviousMessagesEvent extends MessagesEvent {
  const FetchPreviousMessagesEvent(this.chat, this.lastMessage);

  final ChatModel chat;
  final MessageModel lastMessage;

  @override
  List<Object> get props => <Object>[chat, lastMessage];

  @override
  String toString() =>
      'FetchPreviousMessagesEvent { chat: $chat, lastMessage: $lastMessage }';
}

class SendTextMessageEvent extends MessagesEvent {
  const SendTextMessageEvent(this.chatId, this.sender, this.text);

  final String chatId, text;
  final UserModel sender;

  @override
  List<Object> get props => <Object>[chatId, sender, text];

  @override
  String toString() =>
      'SendTextMessageEvent { chatId: $chatId, sender: $sender, text: "$text" }';
}

class SendImageMessageEvent extends MessagesEvent {
  const SendImageMessageEvent(this.chatId, this.sender, this.imageFile);

  final String chatId;
  final UserModel sender;
  final File imageFile;

  @override
  List<Object> get props => <Object>[chatId, sender, imageFile];

  @override
  String toString() =>
      'SendImageMessageEvent { chatId: $chatId, sender: $sender, imageFile: "$imageFile" }';
}
