part of 'contacts_bloc.dart';

abstract class ContactsState extends Equatable {
  const ContactsState();

  @override
  List<Object> get props => <Object>[];
}

class Uninitialized extends ContactsState {}

class FetchingContacts extends ContactsState {}

class ContactsFetched extends ContactsState {
  const ContactsFetched(this.contacts);

  final List<UserModel> contacts;

  @override
  List<Object> get props => <Object>[contacts];

  @override
  String toString() => 'ContactsFetched: { contacts: [ $contacts ] }';
}

class ContactsError extends ContactsState {
  const ContactsError(this.exception);

  final AppException exception;

  @override
  List<Object> get props => <Object>[exception];

  @override
  String toString() => 'ContactsError { exception: ${exception.message} }';
}
