import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

final List<Color> _backgroundColors = <Color>[
  const Color(0xFF004D40),
  const Color(0xFF689F38),
  const Color(0xFF455A64),
  const Color(0xFF5C6BC0),
  const Color(0xFFC2185B),
  const Color(0xFF34691E),
  const Color(0xFF00579B),
  const Color(0xFFF5501B),
  const Color(0xFFB046BC),
  const Color(0xFF0388D2),
  const Color(0xFFEF6C00),
  const Color(0xFFF3511D),
  const Color(0xFFEC417A),
  const Color(0xFF5D4138),
  const Color(0xFF5D6AC0),
  const Color(0xFFBE360B),
  const Color(0xFF679F38),
  const Color(0xFF7B1FA2),
  const Color(0xFF435B63),
  const Color(0xFF00897B),
  const Color(0xFF77919D),
];

class UserModel extends Equatable {
  const UserModel({
    @required this.documentID,
    @required this.email,
    @required this.name,
    // New users that signed up with email/password don't have a photo URL.
    this.photoUrl,
    @required this.status,
  })  : assert(documentID != null),
        assert(email != null),
        assert(name != null),
        assert(status != null);

  factory UserModel.fromJson(String documentID, Map<String, dynamic> json) {
    return UserModel(
      documentID: documentID,
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'status': status,
      };

  final String documentID, email, name, photoUrl, status;

  @override
  List<Object> get props => <Object>[documentID, email, name, photoUrl, status];

  // TODO(cbonello): maybe move to avatar file.
  Color get color {
    final int colorIndex = name.hashCode % _backgroundColors.length;
    return _backgroundColors[colorIndex];
  }

  @override
  String toString() {
    return '''UserModel {
      documentID: "$documentID",
      email: "$email",
      name: "$name",
      photoUrl: "#$photoUrl",
      status: "$status",
    }''';
  }
}
