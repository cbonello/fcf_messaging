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
      yield* mapFetchMessagesEventToState(event.chatId);
    }
    if (event is ReceivedFirstMessagesEvent) {
      yield MessagesFetched(event.messages, false);
    }
    if (event is FetchPreviousMessagesEvent) {
      yield* mapFetchPreviousMessagesEventToState(event.chat, event.lastMessage);
    }
    if (event is SendTextMessageEvent) {
      yield* mapSendTextMessageEventToState(event.chatId, event.sender, event.text);
    }
    if (event is SendImageMessageEvent) {
      yield* mapSendImageMessageEventToState(event.chatId, event.sender, event.imageFile);
    }
  }

  Stream<MessagesState> mapFetchMessagesEventToState(String chatId) async* {
    try {
      yield FetchingMessage();
      await _messagesSubscription[chatId]?.cancel();
      _messagesSubscription[chatId] = _cache.getFirstChatMessages(chatId).listen(
            (List<MessageModel> messages) => add(ReceivedFirstMessagesEvent(messages)),
          );
    } on AppException catch (exception) {
      yield MessagesError(exception);
    }
  }

  Stream<MessagesState> mapFetchPreviousMessagesEventToState(
    ChatModel chat,
    MessageModel lastMessage,
  ) async* {
    try {
      final String chatId = chat.documentID;
      final List<MessageModel> messages =
          await _cache.getPreviousChatMessages(chatId, lastMessage);
      yield MessagesFetched(messages, true);
    } on AppException catch (exception) {
      yield MessagesError(exception);
    }
  }

  Stream<MessagesState> mapSendTextMessageEventToState(
    String chatId,
    RegisteredUserModel sender,
    String text,
  ) async* {
    yield SendingMessage();
    try {
      unawaited(_cache.sendTextMessage(chatId, sender, text));
      yield MessageSent();
    } on TimeoutException {
      _messagesSubscription[chatId]?.resume();
    } catch (exception) {
      yield MessagesError(AppException.from(exception));
    }
  }

  Stream<MessagesState> mapSendImageMessageEventToState(
    String chatId,
    RegisteredUserModel sender,
    File imageFile,
  ) async* {
    yield SendingMessage();
    try {
      unawaited(_cache.sendImageMessage(chatId, sender, imageFile));
      yield MessageSent();
    } on TimeoutException {
      _messagesSubscription[chatId]?.resume();
    } catch (exception) {
      yield MessagesError(AppException.from(exception));
    }
  }
}
