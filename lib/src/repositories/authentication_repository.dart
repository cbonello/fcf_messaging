import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/repositories/users_repository.dart';
import 'package:fcf_messaging/src/utils/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lumberdash/lumberdash.dart';

abstract class AuthenticationRepositoryInterface {
  Future<RegisteredUserModel> signInWithCurrentUser();
  Future<RegisteredUserModel> signInWithEmailAndPassword({String email, String password});
  Future<RegisteredUserModel> signInWithGoogle();
  Future<RegisteredUserModel> signUp({String name, String email, String password});
  Future<void> signOut();
}

class AuthenticationRepository implements AuthenticationRepositoryInterface {
  AuthenticationRepository({
    FirebaseAuth firebaseAuth,
    GoogleSignIn googleSignin,
    @required UsersRepository usersRepository,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn(),
        _usersRepository = usersRepository;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UsersRepository _usersRepository;

  @override
  Future<RegisteredUserModel> signInWithCurrentUser() async {
    final FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    if (firebaseUser != null) {
      try {
        final RegisteredUserModel user = await _usersRepository.getUser(firebaseUser.uid);
        // await _firestoreService.updateActivity(user.email, true);
        return user;
      } catch (_) {
        await signOut();
      }
    }
    return null;
  }

  @override
  Future<RegisteredUserModel> signInWithEmailAndPassword(
      {String email, String password}) async {
    AuthResult authResult;
    try {
      authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (authResult.user.isEmailVerified == false) {
        throw AppException.fromCode('ERROR_EMAIL_NOT_VERIFIED');
      }
    } catch (exception) {
      throw AppException.from(exception);
    }
    try {
      final FirebaseUser firebaseUser = authResult.user;
      final RegisteredUserModel user = await _usersRepository.getUser(firebaseUser.uid);
      if (user != null) {
        // await _firestoreService.updateActivity(firebaseUser.uid, true);
      } else {
        _throwError(
          code: 'ERROR_USER_NOT_FOUND',
          message: 'A signed in user is not registered in the "/users" collection',
          extras: <String, String>{
            'name': firebaseUser.displayName,
            'email': email,
            'photoUrl': firebaseUser.photoUrl ?? '',
          },
        );
      }
      return user;
    } catch (exception) {
      await signOut();
      throw AppException.from(exception);
    }
  }

  @override
  Future<RegisteredUserModel> signInWithGoogle() async {
    AuthResult authResult;
    try {
      final GoogleSignInAccount account = await _googleSignIn.signIn();
      if (account == null) {
        throw AppException.fromCode('ERROR_SiGN_IN_CANCEL');
      }
      final GoogleSignInAuthentication auth = await account.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );
      authResult = await _firebaseAuth.signInWithCredential(
        credential,
      );
    } catch (exception) {
      throw AppException.from(exception);
    }
    try {
      final FirebaseUser firebaseUser = authResult.user;
      RegisteredUserModel user = await _usersRepository.getUser(firebaseUser.uid);
      user ??= await _usersRepository.setUser(
        firebaseUser.uid,
        firebaseUser.displayName,
        firebaseUser.email,
        firebaseUser.photoUrl,
      );
      return user;
    } catch (exception) {
      await signOut();
      throw AppException.from(exception);
    }
  }

  @override
  Future<RegisteredUserModel> signUp({String name, String email, String password}) async {
    AuthResult authResult;
    try {
      authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // await authResult.user.sendEmailVerification();
    } catch (exception) {
      throw AppException.from(exception);
    }
    try {
      final FirebaseUser firebaseUser = authResult.user;
      if (await _usersRepository.isNewUser(firebaseUser.uid) == false) {
        throw const AppException('ERROR_EMAIL_ALREADY_IN_USE');
      }
      final RegisteredUserModel user = await _usersRepository.setUser(
        firebaseUser.uid,
        name,
        email,
        firebaseUser.photoUrl,
      );
      return user;
    } catch (exception) {
      throw AppException.from(exception);
    }
  }

  @override
  Future<void> signOut() async {
    // TODO(cbonello): Update activity.
    try {
      await Future.wait<void>(<Future<void>>[
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (exception, stacktrace) {
      logError(exception, stacktrace: stacktrace);
    }
  }

  void _throwError({
    @required String code,
    @required String message,
    Map<String, String> extras,
  }) {
    logWarning(message, extras: extras);
    throw AppException.fromCode(code);
  }
}
