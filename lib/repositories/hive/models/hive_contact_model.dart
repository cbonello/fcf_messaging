import 'package:fcf_messaging/models/contact_model.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'hive_contact_model.g.dart';

@HiveType(typeId: 2)
class HiveContactModel extends HiveObject {
  HiveContactModel({
    @required this.documentID,
    @required this.name,
    @required this.emails,
    this.photoUrl,
  });

  factory HiveContactModel.fromContactModel(ContactModel contact) {
    return HiveContactModel(
      documentID: contact.documentID,
      name: contact.name,
      emails: contact.emails,
      photoUrl: contact.photoUrl,
    );
  }

  ContactModel toContactModel() => ContactModel(
        documentID: documentID,
        name: name,
        emails: emails,
        photoUrl: photoUrl,
      );

  @HiveField(0)
  final String documentID;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String photoUrl;

  @HiveField(3)
  final List<String> emails;

  @override
  String toString() {
    return '''HiveContactModel {
      documentID: "$documentID",
      name: "$name",
      emails: [ $emails ],
      photoUrl: "#$photoUrl",
    }''';
  }
}
