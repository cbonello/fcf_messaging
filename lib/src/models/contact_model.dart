import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class ContactModel extends Equatable {
  const ContactModel({
    @required this.name,
    @required this.defaultEmail,
    @required this.emails,
    this.photo,
  })  : assert(name != null),
        assert(defaultEmail != null),
        assert(emails != null);

  factory ContactModel.fromContact(Contact contact, String defaultEmail) {
    final List<String> emails = contact.emails.map((Item i) => i.value).toList()..sort();

    return ContactModel(
      name: contact.displayName,
      defaultEmail: defaultEmail,
      emails: emails,
      photo: contact.avatar,
    );
  }

  final String name, defaultEmail;
  final Uint8List photo;
  final List<String> emails;

  @override
  List<Object> get props => <Object>[name, defaultEmail, emails, photo];

  @override
  String toString() {
    return '''ContactModel {
      name: "$name",
      defaultEmail: "$defaultEmail",
      emails: [ $emails ],
      photo: "#$photo",
    }''';
  }
}
