part of 'contacts_bloc.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();
}

class AddContact extends ContactsEvent {
  const AddContact(this.contact);

  final UserModel contact;

  @override
  List<Object> get props => <Object>[contact];

  @override
  String toString() => 'AddContact { contact: $contact }';
}

class ContactsReceivedFromCache extends ContactsEvent {
  const ContactsReceivedFromCache(this.contacts);

  final List<UserModel> contacts;

  @override
  List<Object> get props => <Object>[contacts];

  @override
  String toString() => 'ContactsReceivedFromCache { contacts: [ $contacts ] }';
}
