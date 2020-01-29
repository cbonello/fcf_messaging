import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fcf_messaging/constants.dart';
import 'package:fcf_messaging/models/chat_model.dart';
import 'package:fcf_messaging/models/contact_model.dart';
import 'package:fcf_messaging/models/message_model.dart';
import 'package:fcf_messaging/models/user_model.dart';
import 'package:path/path.dart' as path;

abstract class IFirestoreRepositoryUsers {
  Future<UserModel> getUser(String uid);
  Future<UserModel> setUser(String uid, String name, String email, [String photoUrl]);
  Future<bool> isNewUser(String uid);
}

abstract class IFirestoreRepositoryChats {
  Future<void> addChat(ChatModel chat);
  Stream<List<ChatModel>> readChats(String uid);
}

abstract class IFirestoreRepositoryContacts {
  Future<void> addContact(String uid, ContactModel contact);
  Stream<List<ContactModel>> readContacts(String uid);
}

abstract class IFirestoreRepositoryMessages {
  Stream<List<MessageModel>> getFirstChatMessages(String chatId);
  Future<List<MessageModel>> getPreviousChatMessages(
    String chatId,
    MessageModel prevMessage,
  );
  Future<void> sendTextMessage(String chatId, UserModel sender, String text);
  Future<void> sendImageMessage(String chatId, UserModel sender, File imageFile);
  Future<List<ImageMessageModel>> getImageAttachments(String chatId);
}

class FirestoreRepository
    implements
        IFirestoreRepositoryUsers,
        IFirestoreRepositoryChats,
        IFirestoreRepositoryContacts,
        IFirestoreRepositoryMessages {
  FirestoreRepository({
    Firestore firestoreService,
    FirebaseStorage firebaseStorage,
    this.timeout = DEFAULT_MESSAGE_SEND_TIMEOUT,
  })  : _firestoreService = firestoreService ?? Firestore.instance,
        _firebaseStorage = firebaseStorage ?? FirebaseStorage.instance;

  final Firestore _firestoreService;
  final FirebaseStorage _firebaseStorage;
  final Duration timeout;

  @override
  Future<UserModel> getUser(String uid) async {
    final DocumentReference ref = _firestoreService.collection(USERS_PATH).document(uid);
    final DocumentSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      final UserModel user = UserModel.fromJson(ref.documentID, snapshot.data);
      return user;
    }
    return null;
  }

  // IFirestoreRepositoryUsers

  @override
  Future<UserModel> setUser(
    String uid,
    String name,
    String email, [
    String photoUrl,
  ]) async {
    final DocumentReference ref = _firestoreService.collection(USERS_PATH).document(uid);
    final Map<String, dynamic> data = <String, dynamic>{
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'status': DEFAULT_STATUS,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await ref.setData(data);
    final UserModel user = UserModel.fromJson(uid, data);
    return user;
  }

  @override
  Future<bool> isNewUser(String uid) async {
    final UserModel user = await getUser(uid);
    return user == null;
  }

  // Future<UserModel> updateName(UserModel user, String name) async {
  //   final String normalizedName = name.trim();

  //   if (user.name != normalizedName) {
  //     try {
  //       final DocumentReference ref =
  //           firestoreService.collection(USERS_PATH).document(user.email);
  //       final Map<String, dynamic> data = user.toMap();
  //       data['name'] = name;
  //       await ref.updateData(data);
  //       final UserModel updatedUser = UserModel.fromMap(data);
  //       if (_cache.containsKey(user.email)) {
  //         _cache.set(user.email, updatedUser);
  //       }
  //       return updatedUser;
  //     } catch (exception) {
  //       throw AppException.from(exception);
  //     }
  //   }
  //   return user;
  // }

  // Future<UserModel> updatePhoto(UserModel user, File avatarImageFile) async {
  //   final String firestoreFileName = user.email;
  //   try {
  //     final StorageReference reference =
  //         FirebaseStorage.instance.ref().child(AVATAR_FOLDER).child(
  //               firestoreFileName,
  //             );
  //     final StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
  //     final StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
  //     final String photoUrl = await storageTaskSnapshot.ref.getDownloadURL();
  //     final DocumentReference ref =
  //         firestoreService.collection(USERS_PATH).document(user.email);
  //     final Map<String, dynamic> data = user.toMap();
  //     data['photoUrl'] = photoUrl;
  //     await ref.updateData(data);
  //     final UserModel updatedUser = UserModel.fromMap(data);
  //     if (_cache.containsKey(user.email)) {
  //       _cache.set(user.email, updatedUser);
  //     }
  //     return updatedUser;
  //   } catch (exception) {
  //     throw AppException.from(exception);
  //   }
  // }

  // Future<UserModel> updateStatus(UserModel user, String status) async {
  //   final String normalizedStatus = status.trim();

  //   if (user.status != normalizedStatus) {
  //     try {
  //       final DocumentReference ref =
  //           firestoreService.collection(USERS_PATH).document(user.email);
  //       final Map<String, dynamic> data = user.toMap();
  //       data['status'] = status;
  //       await ref.updateData(data);
  //       final UserModel updatedUser = UserModel.fromMap(data);
  //       if (_cache.containsKey(user.email)) {
  //         _cache.set(user.email, updatedUser);
  //       }
  //       return updatedUser;
  //     } catch (exception) {
  //       throw AppException.from(exception);
  //     }
  //   }

  //   return user;
  // }

  // Future<void> updateActivity(String email, bool isActive) async {
  //   final String normalizedEmail = email.toLowerCase();
  //   final DocumentReference ref =
  //       firestoreService.collection(USERS_PATH).document(normalizedEmail);
  //   final DocumentSnapshot snapshot = await ref.get();
  //   if (snapshot != null && snapshot.exists) {
  //     snapshot.data['isActive'] = isActive;
  //     try {
  //       await firestoreService.runTransaction((Transaction tx) async {
  //         await ref.updateData(snapshot.data);
  //       }).timeout(timeout);
  //       if (_cache.containsKey(email)) {
  //         final UserModel updatedUser = UserModel.fromMap(snapshot.data);
  //         _cache.set(email, updatedUser);
  //       }
  //     } catch (_) {
  //       // Database update may fail with a TimeoutException. Users's activity
  //       // status will be updated when network comes back.
  //     }
  //   }
  // }

  // Future<void> updateFCMToken(UserModel user) async {
  //   Future<void> saveToken(UserModel user) async {
  //     final String fcmToken =
  //         await FirebaseMessagingService.getInstance().firebaseMessaging.getToken();
  //     if (fcmToken != null) {
  //       final String normalizedEmail = user.email.toLowerCase();
  //       final DocumentReference ref = firestoreService
  //           .collection(USERS_PATH)
  //           .document(normalizedEmail)
  //           .collection(TOKENS_PATH)
  //           .document(fcmToken);
  //       final DocumentSnapshot snapshot = await ref.get();
  //       if (snapshot == null || snapshot.exists == false) {
  //         try {
  //           await firestoreService.runTransaction((Transaction tx) async {
  //             await ref.setData(<String, dynamic>{
  //               'token': fcmToken,
  //               'createdAt': FieldValue.serverTimestamp(),
  //               'platform': Platform.operatingSystem
  //             });
  //           }).timeout(timeout);
  //         } catch (_) {}
  //       }
  //     }
  //   }

  //   if (Platform.isIOS) {
  //     final FirebaseMessaging service =
  //         FirebaseMessagingService.getInstance().firebaseMessaging;
  //     service.onIosSettingsRegistered.listen(
  //       (IosNotificationSettings _) => saveToken(user),
  //     );
  //     service.requestNotificationPermissions(const IosNotificationSettings());
  //   } else {
  //     await saveToken(user);
  //   }
  // }

  // IFirestoreRepositoryChats

  @override
  Future<void> addChat(ChatModel chat) async {
    final DocumentReference docRef = _firestoreService.collection(CHATS_PATH).document();
    final Map<String, dynamic> data = chat.toJson();
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
            chats.add(ChatModel.fromJson(document.documentID, document.data));
          }
          sink.add(chats);
        },
      ),
    );
  }

  // IFirestoreRepositoryContacts

  @override
  Future<void> addContact(String uid, ContactModel contact) async {
    final DocumentReference docRef = _firestoreService
        .collection(USERS_PATH)
        .document(uid)
        .collection(CONTACTS_PATH)
        .document();
    final Map<String, dynamic> data = contact.toJson();
    await docRef.setData(data);
  }

  @override
  Stream<List<ContactModel>> readContacts(String uid) {
    return _firestoreService
        .collection(USERS_PATH)
        .document(uid)
        .collection(CONTACTS_PATH)
        .snapshots()
        .transform(
      StreamTransformer<QuerySnapshot, List<ContactModel>>.fromHandlers(
        handleData: (QuerySnapshot snapshot, EventSink<List<ContactModel>> sink) {
          final List<ContactModel> contacts = <ContactModel>[];
          final List<DocumentSnapshot> documents = snapshot.documents;
          for (DocumentSnapshot document in documents) {
            contacts.add(ContactModel.fromJson(document.documentID, document.data));
          }
          sink.add(contacts);
        },
      ),
    );
  }

  // IFirestoreRepositoryMessages

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
  Future<void> sendTextMessage(String chatId, UserModel sender, String text) async {
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
  Future<void> sendImageMessage(String chatId, UserModel sender, File imageFile) async {
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
