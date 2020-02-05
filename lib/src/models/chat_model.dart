import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:meta/meta.dart';

class ChatModel extends Equatable {
  const ChatModel({
    @required this.documentID,
    this.private = false,
    @required this.members,
    this.name,
    this.photoUrl,
    @required this.createdAt,
  })  : assert(documentID != null),
        assert(members != null),
        assert(createdAt != null);

  factory ChatModel.fromJson(String documentID, Map<String, dynamic> json) {
    assert(json['members'] != null);
    final List<RegisteredUserModel> members = List<RegisteredUserModel>.from(
      json['members'].map(
        (dynamic m) {
          final Map<String, dynamic> json = Map<String, dynamic>.from(m);
          final String userID = json['userID'];
          assert(userID != null);
          return RegisteredUserModel.fromJson(userID, json);
        },
      ),
    );

    // <Object>[obj1, obj2] and <Object>[obj2, obj1] are not considered as equal by
    // Equatable. Members are therefore sorted to ensure equality.
    members.sort(
      (RegisteredUserModel m1, RegisteredUserModel m2) => m1.userID.compareTo(m2.userID),
    );

    final String name = json['name'];
    final String photoUrl = json['photoUrl'];

    return ChatModel(
      documentID: documentID,
      private: json['private'],
      members: members,
      name: name,
      photoUrl: photoUrl,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'private': private,
        'membersID':
            List<String>.from(members.map<String>((RegisteredUserModel m) => m.userID)),
        'members': List<dynamic>.from(
            members.map<dynamic>((RegisteredUserModel m) => m.toJson())),
        'name': name,
        'photoUrl': photoUrl,
        'createdAt': createdAt,
      };

  final bool private;
  final List<RegisteredUserModel> members;
  final String documentID, name, photoUrl;
  final Timestamp createdAt;

  @override
  List<Object> get props =>
      <Object>[documentID, private, name, photoUrl, members, createdAt];

  bool get isDirect => members.length == 2;
  bool get isGroup => members.length > 2;

  @override
  String toString() {
    return '''ChatModel {
      documentID: "$documentID",
      private,: $private,
      members: [ $members ], 
      name,: "$name",
      photoUrl: "$photoUrl",
      createdAt: "$createdAt",
    }''';
  }
}
