part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => <Object>[];
}

class Uninitialized extends AuthenticationState {}

class DisplaySplashScreen extends AuthenticationState {}

class DisplayOnboarding extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  const Authenticated({@required this.user}) : assert(user != null);

  final UserModel user;

  @override
  List<Object> get props => <Object>[user];

  @override
  String toString() => 'Authenticated { user: $user }';
}

class Unauthenticated extends AuthenticationState {}
