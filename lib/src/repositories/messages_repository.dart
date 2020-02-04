import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcf_messaging/src/models/message_model.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fcf_messaging/constants.dart';
import 'package:path/path.dart' as path;

abstract class MessagesRepositoryInterface {
  Stream<List<MessageModel>> getFirstChatMessages(String chatId);
  Future<List<MessageModel>> getPreviousChatMessages(
    String chatId,
    MessageModel prevMessage,
  );
  Future<void> sendTextMessage(String chatId, RegisteredUserModel sender, String text);
  Future<void> sendImageMessage(
    String chatId,
    RegisteredUserModel sender,
    File imageFile,
  );
  Future<List<ImageMessageModel>> getImageAttachments(String chatId);
}

class MessagesRepository implements MessagesRepositoryInterface {
  MessagesRepository({
    Firestore firestoreService,
    FirebaseStorage firebaseStorage,
    this.timeout = DEFAULT_MESSAGE_SEND_TIMEOUT,
  })  : _firestoreService = firestoreService ?? Firestore.instance,
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  final Firestore _firestoreService;
  final FirebaseStorage _firebaseStorage;
  final Duration timeout;

  @override
  Stream<List<MessageModel>> getFirstChatMessages(String chatId) {
    return _firestoreService
        .collection(CHATS_PATH)
        .document(chatId)
        .collection(MESSAGES_PATH)
        .orderBy('timestamp', descending: true)
        .limit(MESSAGES_LOAD_LIMIT)
        .snapshots()
        .transform(
      StreamTransformer<QuerySnapshot, List<MessageModel>>.fromHandlers(
        handleData: (QuerySnapshot querySnapshot, EventSink<List<MessageModel>> sink) {
          return _mapSnapshotToMessageModel(querySnapshot, sink);
        },
      ),
    );
  }

  void _mapSnapshotToMessageModel(
    QuerySnapshot querySnapshot,
    EventSink<List<MessageModel>> sink,
  ) {
    final List<MessageModel> messages = <MessageModel>[];
    for (DocumentSnapshot document in querySnapshot.documents) {
      messages.add(MessageModel.fromJson(document.documentID, document.data));
    }
    sink.add(messages);
  }

  @override
  Future<List<MessageModel>> getPreviousChatMessages(
    String chatId,
    MessageModel prevMessage,
  ) async {
    assert(prevMessage.documentID != null);
    final CollectionReference messagesRef = _firestoreService
        .collection(CHATS_PATH)
        .document(chatId)
        .collection(MESSAGES_PATH);
    final DocumentSnapshot lastDocumentRead =
        await messagesRef.document(prevMessage.documentID).get();
    final Query query = messagesRef
        .startAfterDocument(lastDocumentRead)
        .orderBy('timestamp', descending: true)
        .limit(MESSAGES_LOAD_LIMIT);
    final List<MessageModel> messageList = <MessageModel>[];
    final QuerySnapshot messgesSnapshot = await query.getDocuments();
    for (final DocumentSnapshot document in messgesSnapshot.documents) {
      messageList.add(MessageModel.fromJson(document.documentID, document.data));
    }
    return messageList;
  }

  @override
  Future<void> sendTextMessage(
      String chatId, RegisteredUserModel sender, String text) async {
    final DocumentReference ref = _firestoreService
        .collection(CHATS_PATH)
        .document(chatId)
        .collection(MESSAGES_PATH)
        .document();
    final Map<String, dynamic> data = <String, dynamic>{
      'sender': sender.email,
      'text': text,
      'type': MESSAGE_TEXT_TYPE,
      'timestamp': FieldValue.serverTimestamp(),
    };
    // A TimeoutException will be raised if network is down.
    await _firestoreService.runTransaction((Transaction tx) async {
      await ref.setData(data);
    }).timeout(timeout);
  }

  @override
  Future<void> sendImageMessage(
      String chatId, RegisteredUserModel sender, File imageFile) async {
    final StorageReference reference = _firebaseStorage
        .ref()
        .child(CHATS_FOLDER)
        .child(chatId)
        .child(IMAGES_FOLDER)
        .child(path.basename(imageFile.path));
    final StorageUploadTask uploadTask = reference.putFile(imageFile);
    final StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    final String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
    final DocumentReference ref = _firestoreService
        .collection(CHATS_PATH)
        .document(chatId)
        .collection(MESSAGES_PATH)
        .document();
    final Map<String, dynamic> data = <String, dynamic>{
      'sender': sender.email,
      'imageUrl': imageUrl,
      'type': MESSAGE_IMAGE_TYPE,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestoreService.runTransaction((Transaction tx) async {
      await ref.setData(data);
    }).timeout(timeout);
  }

  @override
  Future<List<ImageMessageModel>> getImageAttachments(String chatId) async {
    final QuerySnapshot messgesSnapshot = await _firestoreService
        .collection(CHATS_PATH)
        .document(chatId)
        .collection(MESSAGES_PATH)
        .where('type', isEqualTo: MESSAGE_IMAGE_TYPE)
        .orderBy('timestamp', descending: true)
        .getDocuments();
    final List<ImageMessageModel> messages = <ImageMessageModel>[];
    for (final DocumentSnapshot doc in messgesSnapshot.documents) {
      assert(doc.data['imageUrl'] != null);
      messages.add(ImageMessageModel.fromJson(doc.documentID, doc.data));
    }
    return messages;
  }
}
