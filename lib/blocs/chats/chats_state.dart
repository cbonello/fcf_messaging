part of 'chats_bloc.dart';

abstract class ChatsState extends Equatable {
  const ChatsState();

  @override
  List<Object> get props => <Object>[];
}

class Uninitialized extends ChatsState {}

class FetchingChats extends ChatsState {}

class ChatsFetched extends ChatsState {
  const ChatsFetched(this.chats);

  final List<ChatWithLastMessageModel> chats;

  @override
  List<Object> get props => <Object>[chats];

  @override
  String toString() => 'ChatsFetched: { chats: [ $chats ] }';
}

class ChatsError extends ChatsState {
  const ChatsError(this.exception);

  final AppException exception;

  @override
  List<Object> get props => <Object>[exception];

  @override
  String toString() => 'ChatsError { exception: ${exception.message} }';
}
