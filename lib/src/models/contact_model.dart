import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

class ContactModel extends Equatable {
  const ContactModel({
    @required this.documentID,
    @required this.name,
    @required this.emails,
    this.photoUrl,
  })  : assert(documentID != null),
        assert(name != null),
        assert(emails != null);

  factory ContactModel.fromJson(String documentID, Map<String, dynamic> json) {
    assert(json['emails'] != null);
    final List<String> emails = json['emails']..sort();

    return ContactModel(
      documentID: documentID,
      name: json['name'],
      emails: emails,
      photoUrl: json['photoUrl'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'emails': emails,
        'photoUrl': photoUrl,
      };

  final String documentID, name, photoUrl;
  final List<String> emails;

  @override
  List<Object> get props => <Object>[documentID, name, emails, photoUrl];

  @override
  String toString() {
    return '''ContactModel {
      documentID: "$documentID",
      name: "$name",
      emails: [ $emails ],
      photoUrl: "#$photoUrl",
    }''';
  }
}
