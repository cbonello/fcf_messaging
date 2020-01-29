import 'package:fcf_messaging/locator.dart';
import 'package:fcf_messaging/models/chat_model.dart';
import 'package:fcf_messaging/models/user_model.dart';
import 'package:fcf_messaging/repositories/firestore_repository.dart';
import 'package:fcf_messaging/repositories/hive/hive_repository.dart';
import 'package:flutter/material.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({Key key, @required this.authenticatedUser}) : super(key: key);

  final UserModel authenticatedUser;

  @override
  Widget build(BuildContext context) {
    final FirestoreRepository firestoreService = locator<FirestoreRepository>();
    final HiveRepository hiveService = locator<HiveRepository>();

    return Center(
      child: StreamBuilder<List<ChatModel>>(
        stream: firestoreService.readChats('abcd'), //authenticatedUser.documentID),
        builder: (BuildContext context, AsyncSnapshot<List<ChatModel>> snapshot) {
          if (snapshot.hasData && snapshot.data.isNotEmpty) {
            final ChatModel chat = snapshot.data[0];
            hiveService.addChat(chat);
            return Column(
              children: <Widget>[
                Text(chat.members[0].name),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
