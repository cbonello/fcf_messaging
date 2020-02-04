import 'dart:typed_data';

import 'package:contacts_service/contacts_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

abstract class UserModel extends Equatable {
  const UserModel({
    @required this.name,
    @required this.email,
  })  : assert(name != null),
        assert(email != null);

  final String name, email;

  @override
  List<Object> get props => <Object>[name, email];
}

class RegisteredUserModel extends UserModel implements Equatable {
  const RegisteredUserModel({
    @required this.userID,
    @required String name,
    @required String email,
    @required this.status,
    // New users who signed up with email and password don't have a profile picture.
    this.photoUrl,
  })  : assert(userID != null),
        assert(status != null),
        super(name: name, email: email);

  factory RegisteredUserModel.fromJson(String userID, Map<String, dynamic> json) {
    return RegisteredUserModel(
      userID: userID,
      name: json['name'],
      email: json['email'],
      status: json['status'],
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userID': userID,
        'name': name,
        'email': email,
        'status': status,
        'photoUrl': photoUrl,
      };

  final String userID, status, photoUrl;

  @override
  List<Object> get props => <Object>[userID, status, photoUrl];

  @override
  String toString() {
    return '''RegisteredUserModel {
      userID: "$userID",
      email: "$email",
      name: "$name",
      status: "$status",
      photoUrl: "#$photoUrl",
    }''';
  }
}

class UnregisteredUserModel extends UserModel implements Equatable {
  const UnregisteredUserModel({
    @required String name,
    @required String defaultEmail,
    @required this.emails,
    this.photo,
  })  : assert(emails != null),
        super(name: name, email: defaultEmail);

  factory UnregisteredUserModel.fromContact(Contact contact, String defaultEmail) {
    final List<String> emails = contact.emails.map((Item i) => i.value).toList()..sort();

    return UnregisteredUserModel(
      name: contact.displayName,
      defaultEmail: defaultEmail,
      emails: emails,
      photo: contact.avatar,
    );
  }

  final List<String> emails;
  final Uint8List photo;

  @override
  List<Object> get props => <Object>[emails, photo];

  @override
  String toString() {
    return '''UnregisteredUserModel {
      name: "$name",
      defaultEmail: "$email",
      emails: [ $emails ],
      photo: "#$photo",
    }''';
  }
}
