import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class ChatModel extends Equatable {
  const ChatModel({
    @required this.documentID,
    @required this.private,
    @required this.members,
    this.name,
    this.photoUrl,
    @required this.createdAt,
  })  : assert(documentID != null),
        assert(private != null),
        assert(members != null),
        assert(createdAt != null);

  factory ChatModel.fromJson(String documentID, Map<String, dynamic> json) {
    assert(json['members'] != null);
    final List<ChatMember> membersData = List<ChatMember>.from(
      json['members'].map(
        (dynamic m) => ChatMember.fromJson(Map<String, dynamic>.from(m)),
      ),
    );
    membersData.sort(
      (ChatMember m1, ChatMember m2) => m1.userID.compareTo(m2.userID),
    );
    final String name = json['name'];
    final String photoUrl = json['photoUrl'];

    return ChatModel(
      documentID: documentID,
      private: json['private'],
      members: membersData,
      name: name,
      photoUrl: photoUrl,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'private': private,
        'member': List<dynamic>.from(members.map<dynamic>((ChatMember m) => m.toJson())),
        'name': name,
        'photoUrl': photoUrl,
      };

  final bool private;
  final String documentID, name, photoUrl;
  final List<ChatMember> members;
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
    @required this.createdAt,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      userID: json['userID'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userID': userID,
        'name': name,
        'photoUrl': photoUrl,
        'status': status,
        'createdAt': createdAt,
      };

  final String userID, name, photoUrl, status;
  final Timestamp createdAt;

  @override
  List<Object> get props => <Object>[userID, name, photoUrl, status, createdAt];

  @override
  String toString() {
    return '''ChatMember {
      userID: "$userID",
      name: "$name",
      photoUrl: "#$photoUrl",
      status: "$status",
      createdAt: $createdAt
    }''';
  }
}
