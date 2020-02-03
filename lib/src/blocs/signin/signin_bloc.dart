import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/repositories/authentication_repository.dart';
import 'package:fcf_messaging/src/services/service_locator.dart';
import 'package:fcf_messaging/src/utils/exceptions.dart';
import 'package:fcf_messaging/src/utils/validators.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'signin_event.dart';
part 'signin_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthenticationRepositoryInterface _authenticationRepository =
      locator<AuthenticationRepositoryInterface>();

  @override
  SignInState get initialState => SignInState.empty();

  @override
  Stream<SignInState> transformEvents(
    Stream<SignInEvent> events,
    Stream<SignInState> Function(SignInEvent event) next,
  ) {
    final Stream<SignInEvent> nonDebounceStream = events.where((SignInEvent event) {
      return event is! EmailChanged && event is! PasswordChanged;
    });
    final Stream<SignInEvent> debounceStream = events.where((SignInEvent event) {
      return event is EmailChanged || event is PasswordChanged;
    }).debounceTime(const Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith(<Stream<SignInEvent>>[debounceStream]),
      next,
    );
  }

  @override
  Stream<SignInState> mapEventToState(SignInEvent event) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is SignInWithGooglePressed) {
      yield* _mapSignInWithGooglePressedToState();
    } else if (event is SignInWithEmailAndPasswordPressed) {
      yield* _mapSignInWithEmailAndPasswordPressedToState(
        email: event.email,
        password: event.password,
      );
    }
  }

  Stream<SignInState> _mapEmailChangedToState(String email) async* {
    yield state.update(isEmailValid: isValidEmail(email));
  }

  Stream<SignInState> _mapPasswordChangedToState(String password) async* {
    // Check of password strength is not required; it was done during sign up.
    yield state.update(isPasswordValid: password.isNotEmpty);
  }

  Stream<SignInState> _mapSignInWithEmailAndPasswordPressedToState({
    String email,
    String password,
  }) async* {
    yield SignInState.loading();
    try {
      final UserModel user = await _authenticationRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      yield SignInState.success(user);
    } catch (exception) {
      yield SignInState.failure(AppException.from(exception));
    }
  }

  Stream<SignInState> _mapSignInWithGooglePressedToState() async* {
    try {
      final UserModel user = await _authenticationRepository.signInWithGoogle();
      yield SignInState.success(user);
    } catch (exception) {
      yield SignInState.failure(AppException.from(exception));
    }
  }
}
