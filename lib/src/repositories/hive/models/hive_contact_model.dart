import 'dart:typed_data';

import 'package:fcf_messaging/src/models/contact_model.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'hive_contact_model.g.dart';

@HiveType(typeId: 2)
class HiveContactModel extends HiveObject {
  HiveContactModel({
    @required this.name,
    @required this.defaultEmail,
    @required this.emails,
    this.photo,
  });

  factory HiveContactModel.fromContactModel(ContactModel contact) {
    return HiveContactModel(
      name: contact.name,
      defaultEmail: contact.defaultEmail,
      emails: contact.emails,
      photo: contact.photo,
    );
  }

  ContactModel toContactModel() => ContactModel(
        name: name,
        defaultEmail: defaultEmail,
        emails: emails,
        photo: photo,
      );

  @HiveField(0)
  final String name;

  @HiveField(1)
  final String defaultEmail;

  @HiveField(2)
  final List<String> emails;

  @HiveField(3)
  final Uint8List photo;

  @override
  String toString() {
    return '''HiveContactModel {
      name: "$name",
      defaultEmail: "$defaultEmail",
      emails: [ $emails ],
      photo: "#$photo",
    }''';
  }
}
