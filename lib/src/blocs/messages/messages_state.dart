part of 'messages_bloc.dart';

abstract class MessagesState extends Equatable {
  const MessagesState();

  @override
  List<Object> get props => <Object>[];
}

class MessagesEmpty extends MessagesState {}

class FetchingMessage extends MessagesState {}

class MessagesFetched extends MessagesState {
  const MessagesFetched(this.messages, this.isPrevious);

  final List<MessageModel> messages;
  final bool isPrevious;

  @override
  List<Object> get props => <Object>[messages, isPrevious];

  @override
  String toString() =>
      'FetchedMessagesState: { messages: ${messages.length}, isPrevious: $isPrevious }';
}

class SendingMessage extends MessagesState {}

class MessageSent extends MessagesState {}

class MessagesError extends MessagesState {
  const MessagesError(this.exception);

  final AppException exception;

  @override
  List<Object> get props => <Object>[exception];

  @override
  String toString() => 'MessagesErrorState { exception: ${exception.message} }';
}
