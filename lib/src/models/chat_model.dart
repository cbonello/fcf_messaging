import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
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
    final List<ChatMember> members = List<ChatMember>.from(
      json['members'].map(
        (dynamic m) => ChatMember.fromJson(Map<String, dynamic>.from(m)),
      ),
    );

    // <Object>[obj1, obj2] and <Object>[obj2, obj1] are not considered as equal by
    // Equatable. Members are sorted to ensure equality.
    members.sort(
      (ChatMember m1, ChatMember m2) => m1.userID.compareTo(m2.userID),
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
        'membersID': List<String>.from(members.map<String>((ChatMember m) => m.userID)),
        'members': List<dynamic>.from(members.map<dynamic>((ChatMember m) => m.toJson())),
        'name': name,
        'photoUrl': photoUrl,
        'createdAt': createdAt,
      };

  final bool private;
  final List<ChatMember> members;
  final String documentID, name, photoUrl;
  final Timestamp createdAt;

  @override
  List<Object> get props =>
      <Object>[documentID, private, name, photoUrl, members, createdAt];

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

class ChatMember extends Equatable {
  const ChatMember({
    @required this.userID,
    @required this.name,
    this.photoUrl,
    @required this.status,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      userID: json['userID'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userID': userID,
        'name': name,
        'photoUrl': photoUrl,
        'status': status,
      };

  final String userID, name, photoUrl, status;

  @override
  List<Object> get props => <Object>[userID, name, photoUrl, status];

  @override
  String toString() {
    return '''ChatMember {
      userID: "$userID",
      name: "$name",
      photoUrl: "#$photoUrl",
      status: "$status",
    }''';
  }
}
