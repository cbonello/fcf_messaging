import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/repositories/authentication_repository.dart';
import 'package:fcf_messaging/src/services/local_storage.dart';
import 'package:fcf_messaging/src/services/service_locator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:meta/meta.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({FirebaseAnalytics firebaseAnalytics})
      : _firebaseAnalytics = firebaseAnalytics ?? FirebaseAnalytics();

  final FirebaseAnalytics _firebaseAnalytics;
  final LocalStorageServiceInterface _prefs = locator<LocalStorageServiceInterface>();
  final AuthenticationRepositoryInterface _authenticationRepository =
      locator<AuthenticationRepositoryInterface>();

  @override
  AuthenticationState get initialState => Uninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is StartAuthentication) {
      yield* _mapAuthenticateToState();
    } else if (event is SignedIn) {
      yield* _mapSignedInToState(event.user);
    } else if (event is SignedOut) {
      yield* _mapSignedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    if (_prefs.getDisplayIntroScreen() == true) {
      await _prefs.setDisplayIntroScreen(false);
      yield DisplayIntroScreen();
    } else {
      yield DisplaySplashScreen();
      await Future<void>.delayed(const Duration(seconds: 2), () {});
      add(StartAuthentication());
    }
  }

  Stream<AuthenticationState> _mapAuthenticateToState() async* {
    try {
      final RegisteredUserModel user =
          await _authenticationRepository.signInWithCurrentUser();
      if (user != null) {
        yield Authenticated(user: user);
      } else {
        yield Unauthenticated();
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapSignedInToState(RegisteredUserModel user) async* {
    yield Authenticated(user: user);
    await _firebaseAnalytics.logLogin();
  }

  Stream<AuthenticationState> _mapSignedOutToState() async* {
    await _authenticationRepository.signOut();
    yield Unauthenticated();
  }
}
