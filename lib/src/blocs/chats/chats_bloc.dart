import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fcf_messaging/src/models/chat_with_last_message_model.dart';
import 'package:fcf_messaging/src/models/message_model.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/repositories/cache_repository.dart';
import 'package:fcf_messaging/src/utils/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc(
      {@required RegisteredUserModel user, @required CacheRepositoryChatsInterface cache})
      : _user = user,
        _cache = cache {
    _cacheSub = _cache.readChats(_user.userID).listen(
      (List<ChatWithLastMessageModel> chats) {
        add(ChatsReceivedFromCache(chats));
      },
    );
  }

  final RegisteredUserModel _user;
  final CacheRepositoryChatsInterface _cache;
  StreamSubscription<List<ChatWithLastMessageModel>> _cacheSub;

  @override
  ChatsState get initialState => Uninitialized();

  @override
  Stream<ChatsState> mapEventToState(
    ChatsEvent event,
  ) async* {
    if (event is AddChat) {
      yield* mapAddChatEventToState(event.members, event.name, event.photoUrl);
    } else if (event is ChatsReceivedFromCache) {
      yield* mapChatsReceivedFromCacheEventToState(event.chats);
    }
  }

  Stream<ChatsState> mapAddChatEventToState(
    List<RegisteredUserModel> members,
    String name,
    String photoUrl,
  ) async* {
    try {
      await _cache.addChat(
        members: members,
        name: name,
        photoUrl: photoUrl,
      );
    } catch (e) {
      yield ChatsError(AppException.from(e));
    }
  }

  Stream<ChatsState> mapChatsReceivedFromCacheEventToState(
    List<ChatWithLastMessageModel> chats,
  ) async* {
    try {
      chats.sort((ChatWithLastMessageModel a, ChatWithLastMessageModel b) {
        final MessageModel lma = a.lastMessage;
        final MessageModel lmb = b.lastMessage;
        if (lma == null) {
          return 1;
        }
        if (lmb == null) {
          return -1;
        }
        return lma.timestamp.compareTo(lmb.timestamp);
      });
      yield ChatsFetched(chats);
    } catch (e) {
      yield ChatsError(AppException.from(e));
    }
  }

  @override
  Future<void> close() async {
    await _cacheSub?.cancel();
    return super.close();
  }
}
