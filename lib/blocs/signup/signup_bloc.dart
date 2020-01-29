import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fcf_messaging/locator.dart';
import 'package:fcf_messaging/models/user_model.dart';
import 'package:fcf_messaging/repositories/authentication_repository.dart';
import 'package:fcf_messaging/utils/exceptions.dart';
import 'package:fcf_messaging/utils/validators.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthenticationRepository _authenticationRepository =
      locator<AuthenticationRepository>();

  @override
  SignUpState get initialState => SignUpState.empty();

  @override
  Stream<SignUpState> transformEvents(
    Stream<SignUpEvent> events,
    Stream<SignUpState> Function(SignUpEvent event) next,
  ) {
    final Stream<SignUpEvent> observableStream = events;

    final Stream<SignUpEvent> nonDebounceStream =
        observableStream.where((SignUpEvent event) {
      return event is! EmailChanged && event is! PasswordChanged;
    });
    final Stream<SignUpEvent> debounceStream =
        observableStream.where((SignUpEvent event) {
      return event is EmailChanged || event is PasswordChanged;
    }).debounceTime(const Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith(<Stream<SignUpEvent>>[debounceStream]),
      next,
    );
  }

  @override
  Stream<SignUpState> mapEventToState(
    SignUpEvent event,
  ) async* {
    if (event is NameChanged) {
      yield* _mapNameChangedToState(event.name);
    } else if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is TOSPrivacyChanged) {
      yield* _mapTOSPrivacyChangedToState(event.tosPrivacyAccepted);
    } else if (event is Submitted) {
      yield* _mapFormSubmittedToState(event.name, event.email, event.password);
    }
  }

  Stream<SignUpState> _mapNameChangedToState(String name) async* {
    yield state.update(
      isNameValid: isValidName(name),
    );
  }

  Stream<SignUpState> _mapEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: isValidEmail(email),
    );
  }

  Stream<SignUpState> _mapPasswordChangedToState(String password) async* {
    yield state.update(
      isPasswordValid: isValidPassword(password),
    );
  }

  Stream<SignUpState> _mapTOSPrivacyChangedToState(bool tosPrivacyAccepted) async* {
    yield state.update(
      isTOSPrivacyAccepted: tosPrivacyAccepted,
    );
  }

  Stream<SignUpState> _mapFormSubmittedToState(
    String name,
    String email,
    String password,
  ) async* {
    yield SignUpState.loading();
    try {
      final UserModel user = await _authenticationRepository.signUp(
        name: name,
        email: email,
        password: password,
      );
      yield SignUpState.success(user);
    } catch (exception) {
      yield SignUpState.failure(AppException.from(exception));
    }
  }
}
