import 'package:fcf_messaging/constants.dart';
import 'package:fcf_messaging/src/models/chat_with_last_message_model.dart';
import 'package:fcf_messaging/src/models/message_model.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/screens/widgets/avatars.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const double _HEIGHT = 100.0;
const double _RADIUS = 30.0;

class ChatCard extends StatelessWidget {
  const ChatCard({
    Key key,
    @required ChatWithLastMessageModel chat,
    @required RegisteredUserModel authenticatedUser,
    this.onTap,
  })  : assert(chat != null),
        assert(authenticatedUser != null),
        _chat = chat,
        _authenticatedUser = authenticatedUser,
        super(key: key);

  final ChatWithLastMessageModel _chat;
  final RegisteredUserModel _authenticatedUser;
  final Function() onTap;

  static double height = _HEIGHT;

  @override
  Widget build(BuildContext context) {
    final List<RegisteredUserModel> contacts = _chat.chat.contacts(_authenticatedUser);

    return _Card(
      avatar: ChatCircleAvatar(
        chat: _chat,
        authenticatedUser: _authenticatedUser,
        radius: _RADIUS,
      ),
      line1: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            child: _chat.chat.isDirect
                ? Text(
                    contacts[0].name,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    _chat.chat.name,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          Text(
            _chat.lastMessage?.timestamp != null
                ? DateFormat(DATE_FORMAT).format(
                    _chat.lastMessage.timestamp.toDate(),
                  )
                : '',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          )
        ],
      ),
      line2: Text(
        _prefixedMessage(_authenticatedUser, _chat.lastMessage),
        maxLines: 2,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      height: height,
      onTap: onTap,
    );
  }

  String _prefixedMessage(UserModel currentUser, TextMessageModel message) {
    if (message != null) {
      final String prefix = currentUser.email == message.sender ? 'You: ' : '';
      return '$prefix${message.text}';
    }
    return '';
  }
}

class UserCard extends StatelessWidget {
  const UserCard({
    Key key,
    @required this.user,
    this.onTap,
  }) : super(key: key);

  final RegisteredUserModel user;
  final Function() onTap;

  static double height = _HEIGHT;

  @override
  Widget build(BuildContext context) {
    return _Card(
      avatar: UserCircleAvatar(
        user: user,
        radius: _RADIUS,
        displayActivityIndicator: true,
      ),
      line1: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              user.name,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Text(
          //   user?.lastActive != null
          //       ? DateFormat(DATE_FORMAT).format(
          //           user?.lastActive?.toDate(),
          //         )
          //       : '',
          //   style: const TextStyle(
          //     color: Colors.grey,
          //     fontSize: 12,
          //   ),
          // )
        ],
      ),
      line2: Text(
        user.status,
        maxLines: 2,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
      height: height,
      onTap: onTap,
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    Key key,
    @required this.avatar,
    @required this.line1,
    @required this.line2,
    @required this.height,
    this.onTap,
  }) : super(key: key);

  final Widget avatar;
  final Widget line1, line2;
  final double height;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.withAlpha(50),
              offset: const Offset(0, 0),
              blurRadius: 5,
            ),
          ],
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: <Widget>[
              avatar,
              const SizedBox(width: 15.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(padding: EdgeInsets.only(top: 5)),
                    line1,
                    line2,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
