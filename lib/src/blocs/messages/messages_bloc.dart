import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fcf_messaging/src/models/chat_model.dart';
import 'package:fcf_messaging/src/models/message_model.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/repositories/messages_repository.dart';
import 'package:fcf_messaging/src/utils/exceptions.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  MessagesBloc({@required MessagesRepositoryInterface cache}) : _cache = cache;

  final MessagesRepositoryInterface _cache;
  final Map<String, StreamSubscription<List<MessageModel>>> _messagesSubscription =
      <String, StreamSubscription<List<MessageModel>>>{};

  @override
  MessagesState get initialState => MessagesEmpty();

  @override
  Future<void> close() async {
    _messagesSubscription.forEach(
      (_, StreamSubscription<List<MessageModel>> subscription) async {
        await subscription.cancel();
      },
    );
    await super.close();
  }

  @override
  Stream<MessagesState> mapEventToState(
    MessagesEvent event,
  ) async* {
    if (event is FetchMessagesEvent) {
      yield* mapFetchMessagesEventToState(event);
    }
    if (event is ReceivedFirstMessagesEvent) {
      yield MessagesFetched(event.messages, false);
    }
    if (event is FetchPreviousMessagesEvent) {
      yield* mapFetchPreviousMessagesEventToState(event);
    }
    if (event is SendTextMessageEvent) {
      yield* mapSendTextMessageEventToState(event);
    }
    if (event is SendImageMessageEvent) {
      yield* mapSendImageMessageEventToState(event);
    }
  }

  Stream<MessagesState> mapFetchMessagesEventToState(FetchMessagesEvent event) async* {
    try {
      yield FetchingMessage();
      final String chatId = event.chatId;
      await _messagesSubscription[chatId]?.cancel();
      _messagesSubscription[chatId] = _cache.getFirstChatMessages(chatId).listen(
            (List<MessageModel> messages) => add(ReceivedFirstMessagesEvent(messages)),
          );
    } on AppException catch (exception) {
      yield MessagesError(exception);
    }
  }

  Stream<MessagesState> mapFetchPreviousMessagesEventToState(
    FetchPreviousMessagesEvent event,
  ) async* {
    try {
      final String chatId = event.chat.documentID;
      final List<MessageModel> messages =
          await _cache.getPreviousChatMessages(chatId, event.lastMessage);
      yield MessagesFetched(messages, true);
    } on AppException catch (exception) {
      yield MessagesError(exception);
    }
  }

  Stream<MessagesState> mapSendTextMessageEventToState(
    SendTextMessageEvent event,
  ) async* {
    yield SendingMessage();
    try {
      unawaited(_cache.sendTextMessage(event.chatId, event.sender, event.text));
      yield MessageSent();
    } on TimeoutException {
      _messagesSubscription[event.chatId]?.resume();
    } catch (exception) {
      yield MessagesError(AppException.from(exception));
    }
  }

  Stream<MessagesState> mapSendImageMessageEventToState(
    SendImageMessageEvent event,
  ) async* {
    yield SendingMessage();
    try {
      unawaited(_cache.sendImageMessage(event.chatId, event.sender, event.imageFile));
      yield MessageSent();
    } on TimeoutException {
      _messagesSubscription[event.chatId]?.resume();
    } catch (exception) {
      yield MessagesError(AppException.from(exception));
    }
  }
}
