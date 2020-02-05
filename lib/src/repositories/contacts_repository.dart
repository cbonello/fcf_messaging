// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fcf_messaging/constants.dart';
// import 'package:fcf_messaging/src/models/contact_model.dart';

// abstract class ContactsRepositoryInterface {
//   Future<void> addContact(String uid, ContactModel contact);
//   Stream<List<ContactModel>> readContacts(String uid);
// }

// class ContactsRepository implements ContactsRepositoryInterface {
//   ContactsRepository({
//     Firestore firestoreService,
//     this.timeout = DEFAULT_MESSAGE_SEND_TIMEOUT,
//   }) : _firestoreService = firestoreService ?? Firestore.instance;

//   final Firestore _firestoreService;
//   final Duration timeout;

//   @override
//   Future<void> addContact(String uid, ContactModel contact) async {
//     final DocumentReference docRef = _firestoreService
//         .collection(USERS_PATH)
//         .document(uid)
//         .collection(CONTACTS_PATH)
//         .document();
//     final Map<String, dynamic> data = contact.toJson();
//     await docRef.setData(data);
//   }

//   @override
//   Stream<List<ContactModel>> readContacts(String uid) {
//     return _firestoreService
//         .collection(USERS_PATH)
//         .document(uid)
//         .collection(CONTACTS_PATH)
//         .snapshots()
//         .transform(
//       StreamTransformer<QuerySnapshot, List<ContactModel>>.fromHandlers(
//         handleData: (QuerySnapshot snapshot, EventSink<List<ContactModel>> sink) {
//           final List<ContactModel> contacts = <ContactModel>[];
//           final List<DocumentSnapshot> documents = snapshot.documents;
//           for (DocumentSnapshot document in documents) {
//             contacts.add(ContactModel.fromJson(document.documentID, document.data));
//           }
//           sink.add(contacts);
//         },
//       ),
//     );
//   }
// }
