import 'package:fcf_messaging/src/blocs/chats/chats_bloc.dart';
import 'package:fcf_messaging/src/models/chat_model.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({Key key, @required this.authenticatedUser}) : super(key: key);

  final UserModel authenticatedUser;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsBloc, ChatsState>(
      builder: (BuildContext context, ChatsState state) {
        if (state is Uninitialized) {
          return Container();
        }
        if (state is ChatsError) {
          return Center(child: Text(state.exception.message));
        }
        if (state is ChatsFetched) {
          if (state.chats.isEmpty) {
            return RaisedButton(
              onPressed: () {
                final ChatsBloc chatsBloc = context.bloc<ChatsBloc>();
                chatsBloc.add(
                  AddChat(
                    members: <ChatMember>[
                      ChatMember(
                        userID: authenticatedUser.documentID,
                        name: authenticatedUser.name,
                        status: authenticatedUser.status,
                      ),
                      const ChatMember(
                        userID: 'efgh',
                        name: 'Foo Bar',
                        status: 'Hi',
                      ),
                    ],
                  ),
                );
              },
              child: Text(context.l10n().appTitle),
            );
          }
          return ListView.builder(
            itemCount: state.chats.length,
            // separatorBuilder: (BuildContext context, int index) => const Divider(),
            itemBuilder: (BuildContext context, int index) {
              return Row(
                children: <Widget>[
                  Expanded(child: Text(state.chats[index].chat.documentID)),
                  RaisedButton(
                    onPressed: () {
                      final ChatsBloc chatsBloc = context.bloc<ChatsBloc>();
                      chatsBloc.add(
                        AddChat(
                          members: <ChatMember>[
                            ChatMember(
                              userID: authenticatedUser.documentID,
                              name: authenticatedUser.name,
                              status: authenticatedUser.status,
                            ),
                            const ChatMember(
                              userID: 'efgh',
                              name: 'Foo Bar',
                              status: 'Hi',
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(context.l10n().appTitle),
                  ),
                ],
              );
            },
          );
        }
        return Container();
      },
    );

    // StreamBuilder<List<ChatModel>>(
    //   stream: firestoreService.readChats('abcd'), //authenticatedUser.documentID),
    //   builder: (BuildContext context, AsyncSnapshot<List<ChatModel>> snapshot) {
    //     if (snapshot.hasData && snapshot.data.isNotEmpty) {
    //       final ChatModel chat = snapshot.data[0];
    //       hiveService.addChat(chat);
    //       return Column(
    //         children: <Widget>[
    //           Text(chat.members[0].name),
    //         ],
    //       );
    //     }
    //     return Container();
    //   },
    // ),
  }
}
