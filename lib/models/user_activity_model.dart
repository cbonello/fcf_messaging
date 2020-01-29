import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class UserActivityModel extends Equatable {
  const UserActivityModel({@required this.documentID, @required this.isActive})
      : assert(documentID != null),
        assert(isActive != null);

  factory UserActivityModel.fromJson(String documentID, Map<String, dynamic> json) {
    return UserActivityModel(
      documentID: documentID,
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'isActive': isActive,
      };

  final String documentID;
  final bool isActive;

  @override
  List<Object> get props => <Object>[documentID, isActive];

  @override
  String toString() {
    return '''UserActivityModel {
      documentID: "$documentID",
      isActive: $isActive
    }''';
  }
}
