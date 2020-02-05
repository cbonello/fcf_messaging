import 'dart:typed_data';

import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'hive_user_model.g.dart';

@HiveType(typeId: 2)
class HiveUserModel extends HiveObject {
  HiveUserModel({
    @required this.type,
    @required this.name,
    @required this.email,
    this.userID,
    this.status,
    this.photoUrl,
    this.emails,
    this.photo,
  });

  // ignore: missing_return
  factory HiveUserModel.fromUserModel(UserModel member) {
    if (member is RegisteredUserModel) {
      return HiveUserModel(
        type: 1,
        name: member.name,
        email: member.email,
        userID: member.userID,
        status: member.status,
        photoUrl: member.photoUrl,
      );
    }
    if (member is UnregisteredUserModel) {
      return HiveUserModel(
        type: 2,
        name: member.name,
        email: member.email,
        emails: member.emails,
        photo: member.photo,
      );
    }
  }

  // ignore: missing_return
  RegisteredUserModel toUserModel() {
    if (type == 1) {
      return RegisteredUserModel(
        userID: userID,
        name: name,
        email: email,
        status: status,
        photoUrl: photoUrl,
      );
    }
    if (type == 2) {
      UnregisteredUserModel(
        name: name,
        defaultEmail: email,
        emails: emails,
        photo: photo,
      );
    }
  }

  @HiveField(0)
  final int type;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String userID;

  @HiveField(4)
  final String status;

  @HiveField(5)
  final String photoUrl;

  @HiveField(6)
  final List<String> emails;

  @HiveField(7)
  final Uint8List photo;

  @override
  String toString() {
    if (type == 1) {
      return '''HiveUserModel (Registered) {
      type: $type,
      userID: "$userID",
      name: "$name",
      email: "$email",
      status: "$status",
      photoUrl: "#$photoUrl",
    }''';
    }

    return '''HiveUserModel (Unregistered) {
      name: "$name",
      defaultEmail: "$email",
      emails: [ $emails ],
      photo: "#$photo",
    }''';
  }
}
