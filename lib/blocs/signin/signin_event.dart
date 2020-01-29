part of 'signin_bloc.dart';

abstract class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object> get props => <Object>[];
}

class EmailChanged extends SignInEvent {
  const EmailChanged({@required this.email});

  final String email;

  @override
  List<Object> get props => <Object>[email];

  @override
  String toString() => 'EmailChanged { email :$email }';
}

class PasswordChanged extends SignInEvent {
  const PasswordChanged({@required this.password});

  final String password;

  @override
  List<Object> get props => <Object>[password];

  @override
  String toString() => 'PasswordChanged { password: $password }';
}

class SignInWithEmailAndPasswordPressed extends SignInEvent {
  const SignInWithEmailAndPasswordPressed({
    @required this.email,
    @required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object> get props => <Object>[email, password];

  @override
  String toString() {
    return 'SignInWithEmailAndPasswordPressed { email: "$email", password: "$password" }';
  }
}

class SignInWithGooglePressed extends SignInEvent {}
