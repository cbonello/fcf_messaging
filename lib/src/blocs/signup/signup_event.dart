part of 'signup_bloc.dart';

@immutable
abstract class SignUpEvent extends Equatable {
  const SignUpEvent();
}

class NameChanged extends SignUpEvent {
  const NameChanged({@required this.name});

  final String name;

  @override
  List<Object> get props => <Object>[name];

  @override
  String toString() => 'NameChanged { name :$name }';
}

class EmailChanged extends SignUpEvent {
  const EmailChanged({@required this.email});

  final String email;

  @override
  List<Object> get props => <Object>[email];

  @override
  String toString() => 'EmailChanged { email :$email }';
}

class PasswordChanged extends SignUpEvent {
  const PasswordChanged({@required this.password});

  final String password;

  @override
  List<Object> get props => <Object>[password];

  @override
  String toString() => 'PasswordChanged { password: $password }';
}

class TOSPrivacyChanged extends SignUpEvent {
  const TOSPrivacyChanged({@required this.tosPrivacyAccepted});

  final bool tosPrivacyAccepted;

  @override
  List<Object> get props => <Object>[tosPrivacyAccepted];

  @override
  String toString() => 'TOSPrivacyChanged { TOS/Privacy Accepted: $tosPrivacyAccepted }';
}

class Submitted extends SignUpEvent {
  const Submitted({
    @required this.name,
    @required this.email,
    @required this.password,
    @required this.tosPrivacyAccepted,
  });

  final String name, email, password;
  final bool tosPrivacyAccepted;

  @override
  List<Object> get props => <Object>[
        name,
        email,
        password,
        tosPrivacyAccepted,
      ];

  @override
  String toString() {
    return '''Submitted {
      Name: "$name",
      email: "$email",
      password: "$password",
      TOS/Privacy Accepted: $tosPrivacyAccepted
    }''';
  }
}
