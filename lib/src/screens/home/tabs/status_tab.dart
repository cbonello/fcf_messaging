import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:flutter/material.dart';

class StatusTab extends StatelessWidget {
  const StatusTab({Key key, @required this.authenticatedUser}) : super(key: key);

  final RegisteredUserModel authenticatedUser;

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('STATUS'));
  }
}
