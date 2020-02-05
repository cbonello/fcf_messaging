import 'dart:typed_data';

import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'hive_unregistered_user_model.g.dart';

@HiveType(typeId: 3)
class HiveUnregisteredUserModel extends HiveObject {
  HiveUnregisteredUserModel({
    @required this.name,
    @required this.defaultEmail,
    @required this.emails,
    this.photo,
  });

  factory HiveUnregisteredUserModel.fromUnregisteredUserModel(
      UnregisteredUserModel contact) {
    return HiveUnregisteredUserModel(
      name: contact.name,
      defaultEmail: contact.email,
      emails: contact.emails,
      photo: contact.photo,
    );
  }

  UnregisteredUserModel toUnregisteredUserModel() => UnregisteredUserModel(
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
    return '''HiveUnregisteredUserModel {
      name: "$name",
      defaultEmail: "$defaultEmail",
      emails: [ $emails ],
      photo: "#$photo",
    }''';
  }
}
