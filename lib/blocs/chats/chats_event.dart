part of 'chats_bloc.dart';

abstract class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object> get props => <Object>[];
}

class AddChat extends ChatsEvent {
  const AddChat(this.chat);

  final ChatModel chat;

  @override
  List<Object> get props => <Object>[chat];

  @override
  String toString() => 'AddChat { chat: $chat }';
}

class ChatsReceivedFromCache extends ChatsEvent {
  const ChatsReceivedFromCache(this.chats);

  final List<ChatWithLastMessageModel> chats;

  @override
  List<Object> get props => <Object>[chats];

  @override
  String toString() => 'ChatsReceivedFromCache { chats: [ $chats ] }';
}
