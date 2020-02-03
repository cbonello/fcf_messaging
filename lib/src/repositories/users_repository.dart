import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcf_messaging/constants.dart';
import 'package:fcf_messaging/src/models/user_model.dart';

abstract class UsersRepositoryInterface {
  Future<UserModel> getUser(String uid);
  Future<UserModel> setUser(String uid, String name, String email, [String photoUrl]);
  Future<bool> isNewUser(String uid);
}

class UsersRepository implements UsersRepositoryInterface {
  UsersRepository({
    Firestore firestoreService,
    this.timeout = DEFAULT_MESSAGE_SEND_TIMEOUT,
  }) : _firestoreService = firestoreService ?? Firestore.instance;

  final Firestore _firestoreService;
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
}
