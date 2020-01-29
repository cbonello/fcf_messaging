import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:fcf_messaging/models/chat_model.dart';
import 'package:fcf_messaging/models/chat_with_last_message_model.dart';
import 'package:fcf_messaging/models/message_model.dart';
import 'package:fcf_messaging/models/user_model.dart';
import 'package:fcf_messaging/repositories/cache_repository.dart';
import 'package:fcf_messaging/utils/exceptions.dart';
import 'package:meta/meta.dart';

part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  ChatsBloc({@required UserModel user, @required ICacheRepositoryChats cache})
      : _user = user,
        _cache = cache {
    _cacheSub = _cache.readChats(_user.documentID).listen(
      (List<ChatWithLastMessageModel> chats) {
        add(ChatsReceivedFromCache(chats));
      },
    );
  }

  final UserModel _user;
  final ICacheRepositoryChats _cache;
  StreamSubscription<List<ChatWithLastMessageModel>> _cacheSub;

  @override
  ChatsState get initialState => Uninitialized();

  @override
  Stream<ChatsState> mapEventToState(
    ChatsEvent event,
  ) async* {
    if (event is AddChat) {
      yield* mapAddChatEventToState(event);
    } else if (event is ChatsReceivedFromCache) {
      yield* mapChatsReceivedFromCacheEventToState(event);
    }
  }

  Stream<ChatsState> mapAddChatEventToState(AddChat event) async* {
    try {
      await _cache.addChat(event.chat);
    } catch (e) {
      yield ChatsError(AppException.from(e));
    }
  }

  Stream<ChatsState> mapChatsReceivedFromCacheEventToState(
    ChatsReceivedFromCache event,
  ) async* {
    try {
      event.chats.sort((ChatWithLastMessageModel a, ChatWithLastMessageModel b) {
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
      yield ChatsFetched(event.chats);
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
