import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:flutter/material.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({Key key, @required this.authenticatedUser}) : super(key: key);

  final RegisteredUserModel authenticatedUser;

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('NOTIFICATIONS'));
  }
}
