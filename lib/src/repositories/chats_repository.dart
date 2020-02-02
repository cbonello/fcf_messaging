import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcf_messaging/constants.dart';
import 'package:fcf_messaging/src/models/chat_model.dart';

abstract class ChatsRepositoryInterface {
  Future<void> addChat(ChatModel chat);
  Stream<List<ChatModel>> readChats(String uid);
}

class ChatsRepository implements ChatsRepositoryInterface {
  ChatsRepository({
    Firestore firestoreService,
    this.timeout = DEFAULT_MESSAGE_SEND_TIMEOUT,
  }) : _firestoreService = firestoreService ?? Firestore.instance;

  final Firestore _firestoreService;
  final Duration timeout;

  String generateDocumentID() {
    return _firestoreService.collection(CHATS_PATH).document().documentID;
  }

  @override
  Future<void> addChat(ChatModel chat) async {
    final DocumentReference docRef = _firestoreService.collection(CHATS_PATH).document(
          chat.documentID,
        );
    final Map<String, dynamic> data = chat.toJson();
    print(data);
    await docRef.setData(data);
  }

  @override
  Stream<List<ChatModel>> readChats(String uid) {
    return _firestoreService
        .collection(CHATS_PATH)
        .where('membersID', arrayContains: uid)
        .snapshots()
        .transform(
      StreamTransformer<QuerySnapshot, List<ChatModel>>.fromHandlers(
        handleData: (QuerySnapshot snapshot, EventSink<List<ChatModel>> sink) {
          final List<ChatModel> chats = <ChatModel>[];
          final List<DocumentSnapshot> documents = snapshot.documents;
          for (DocumentSnapshot document in documents) {
            final ChatModel chat = ChatModel.fromJson(document.documentID, document.data);
            chats.add(chat);
          }
          sink.add(chats);
        },
      ),
    );
  }
}
