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
    } else if (event is Authenticate) {
      yield* _mapAuthenticateToState(event);
    } else if (event is SignedIn) {
      yield* _mapSignedInToState(event);
    } else if (event is SignedOut) {
      yield* _mapSignedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    yield DisplaySplashScreen();
    try {
      final UserModel user = await Future<UserModel>.delayed(
        const Duration(seconds: 2),
        () => _authenticationRepository.signInWithCurrentUser(),
      );
      if (_prefs.getDisplayOnboarding() == true) {
        await _prefs.setDisplayOnboarding(false);
        yield DisplayOnboarding(user: user);
      }
      add(Authenticate(user: user));
    } catch (_) {
      yield const DisplayOnboarding(user: null);
    }
  }

  Stream<AuthenticationState> _mapAuthenticateToState(Authenticate event) async* {
    if (event.user != null) {
      yield Authenticated(user: event.user);
    } else {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapSignedInToState(SignedIn event) async* {
    yield Authenticated(user: event.user);
    await _firebaseAnalytics.logLogin();
  }

  Stream<AuthenticationState> _mapSignedOutToState() async* {
    await _authenticationRepository.signOut();
    yield Unauthenticated();
  }
}
