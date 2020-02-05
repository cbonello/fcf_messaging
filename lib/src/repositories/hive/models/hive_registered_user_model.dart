import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'hive_registered_user_model.g.dart';

@HiveType(typeId: 2)
class HiveRegisteredUserModel extends HiveObject {
  HiveRegisteredUserModel({
    @required this.userID,
    @required this.name,
    @required this.email,
    @required this.status,
    this.photoUrl,
  });

  factory HiveRegisteredUserModel.fromRegisteredUserModel(RegisteredUserModel member) {
    return HiveRegisteredUserModel(
      userID: member.userID,
      name: member.name,
      email: member.email,
      status: member.status,
      photoUrl: member.photoUrl,
    );
  }

  RegisteredUserModel toRegisteredUserModel() => RegisteredUserModel(
        userID: userID,
        name: name,
        email: email,
        status: status,
        photoUrl: photoUrl,
      );

  @HiveField(0)
  final String userID;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String status;

  @HiveField(4)
  final String photoUrl;

  @override
  String toString() {
    return '''HiveRegisteredUserModel {
      userID: "$userID",
      name: "$name",
      email: "$email",
      status: "$status",
      photoUrl: "#$photoUrl",
    }''';
  }
}
