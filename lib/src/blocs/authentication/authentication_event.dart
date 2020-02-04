part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => <Object>[];
}

class AppStarted extends AuthenticationEvent {}

class StartAuthentication extends AuthenticationEvent {}

class SignedIn extends AuthenticationEvent {
  const SignedIn({@required this.user}) : assert(user != null);

  final RegisteredUserModel user;

  @override
  List<Object> get props => <Object>[user];

  @override
  String toString() => 'SignedIn { user: $user }';
}

class SignedOut extends AuthenticationEvent {}
