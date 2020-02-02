part of 'chats_bloc.dart';

abstract class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object> get props => <Object>[];
}

class AddChat extends ChatsEvent {
  const AddChat({
    @required this.members,
    this.name,
    this.photoUrl,
  });

  final List<ChatMember> members;
  final String name, photoUrl;

  @override
  List<Object> get props => <Object>[members, name, photoUrl];

  @override
  String toString() =>
      'AddChat { members: [ $members ], name: "$name", photoUrl: "$photoUrl" }';
}

class ChatsReceivedFromCache extends ChatsEvent {
  const ChatsReceivedFromCache(this.chats);

  final List<ChatWithLastMessageModel> chats;

  @override
  List<Object> get props => <Object>[chats];

  @override
  String toString() => 'ChatsReceivedFromCache { chats: [ $chats ] }';
}
