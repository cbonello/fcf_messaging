import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcf_messaging/constants.dart';
import 'package:fcf_messaging/src/models/user_model.dart';

abstract class ContactsRepositoryInterface {
  // String generateDocumentID(String uid);
  Future<void> addContact(String uid, RegisteredUserModel contact);
  Stream<List<RegisteredUserModel>> readContacts(String uid);
}

class ContactsRepository implements ContactsRepositoryInterface {
  ContactsRepository({
    Firestore firestoreService,
    this.timeout = DEFAULT_MESSAGE_SEND_TIMEOUT,
  }) : _firestoreService = firestoreService ?? Firestore.instance;

  final Firestore _firestoreService;
  final Duration timeout;

  // @override
  // String generateDocumentID(String uid) {
  //   return _firestoreService
  //       .collection(USERS_PATH)
  //       .document(uid)
  //       .collection(CONTACTS_PATH)
  //       .document()
  //       .documentID;
  // }

  @override
  Future<void> addContact(String uid, RegisteredUserModel contact) async {
    final DocumentReference docRef = _firestoreService
        .collection(USERS_PATH)
        .document(uid)
        .collection(CONTACTS_PATH)
        .document();
    final Map<String, dynamic> data = contact.toJson();
    await docRef.setData(data);
  }

  @override
  Stream<List<RegisteredUserModel>> readContacts(String uid) {
    return _firestoreService
        .collection(USERS_PATH)
        .document(uid)
        .collection(CONTACTS_PATH)
        .snapshots()
        .transform(
      StreamTransformer<QuerySnapshot, List<RegisteredUserModel>>.fromHandlers(
        handleData: (QuerySnapshot snapshot, EventSink<List<RegisteredUserModel>> sink) {
          final List<RegisteredUserModel> contacts = <RegisteredUserModel>[];
          final List<DocumentSnapshot> documents = snapshot.documents;
          for (DocumentSnapshot document in documents) {
            contacts
                .add(RegisteredUserModel.fromJson(document.documentID, document.data));
          }
          sink.add(contacts);
        },
      ),
    );
  }
}
