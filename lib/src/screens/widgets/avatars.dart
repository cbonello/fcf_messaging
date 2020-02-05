import 'package:cached_network_image/cached_network_image.dart';
import 'package:fcf_messaging/src/models/chat_model.dart';
import 'package:fcf_messaging/src/models/chat_with_last_message_model.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:flutter/material.dart';

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

Color _userAvatarBackgroundColor(UserModel user) {
  final int colorIndex = user.name.hashCode % _backgroundColors.length;
  return _backgroundColors[colorIndex];
}

class ChatCircleAvatar extends StatelessWidget {
  const ChatCircleAvatar({
    Key key,
    @required ChatWithLastMessageModel chat,
    @required RegisteredUserModel authenticatedUser,
    Color backgroundColor,
    this.elevation = 0.0,
    this.radius = 35.0,
    this.onTap,
  })  : assert(chat != null),
        assert(authenticatedUser != null),
        _chat = chat,
        _authenticatedUser = authenticatedUser,
        _backgroundColor = backgroundColor,
        super(key: key);

  final ChatWithLastMessageModel _chat;
  final RegisteredUserModel _authenticatedUser;
  final Color _backgroundColor;
  final double elevation;
  final double radius;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (_chat.chat.photoUrl != null) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: _chat.chat.photoUrl,
            errorWidget: (BuildContext _, String __, Object ___) {
              return _ChatUserCircleAvatar(
                chat: _chat.chat,
                authenticatedUser: _authenticatedUser,
                backgroundColor: _backgroundColor,
                elevation: elevation,
                radius: radius,
              );
            },
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: _ChatUserCircleAvatar(
        chat: _chat.chat,
        authenticatedUser: _authenticatedUser,
        backgroundColor: _backgroundColor,
        elevation: elevation,
        radius: radius,
      ),
    );
  }
}

class _ChatUserCircleAvatar extends StatelessWidget {
  const _ChatUserCircleAvatar({
    Key key,
    @required this.chat,
    @required this.authenticatedUser,
    this.backgroundColor,
    @required this.elevation,
    @required this.radius,
  }) : super(key: key);

  final ChatModel chat;
  final RegisteredUserModel authenticatedUser;
  final Color backgroundColor;
  final double elevation;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final List<RegisteredUserModel> contacts = chat.contacts(authenticatedUser);

    if (chat.isDirect) {
      return UserCircleAvatar(
        user: contacts[0],
        backgroundColor: backgroundColor,
        elevation: elevation,
        radius: radius,
        displayActivityIndicator: true,
      );
    }

    return Container(
      height: 2 * radius,
      width: 2 * radius,
      child: Stack(
        children: <Widget>[
          Positioned(
            right: 0.0,
            top: 0.0,
            child: UserCircleAvatar(
              user: contacts[1],
              backgroundColor: backgroundColor,
              elevation: elevation,
              radius: radius * 0.70,
              displayActivityIndicator: true,
            ),
          ),
          Positioned(
            left: 0.0,
            bottom: 0.0,
            child: UserCircleAvatar(
              user: contacts[0],
              backgroundColor: backgroundColor,
              elevation: elevation,
              radius: radius * 0.70,
              displayActivityIndicator: true,
            ),
          ),
        ],
      ),
    );
  }
}

class UserCircleAvatar extends StatelessWidget {
  const UserCircleAvatar({
    Key key,
    @required RegisteredUserModel user,
    Color backgroundColor,
    this.elevation = 0.0,
    this.radius = 35.0,
    this.displayActivityIndicator = false,
    this.onTap,
  })  : assert(user != null),
        _user = user,
        _backgroundColor = backgroundColor,
        super(key: key);

  final RegisteredUserModel _user;
  final Color _backgroundColor;
  final double elevation;
  final double radius;
  final bool displayActivityIndicator;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: radius * 2,
        width: radius * 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: _backgroundColor ?? _userAvatarBackgroundColor(_user),
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5.0),
          ],
        ),
        child: Center(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              if (_user.photoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: _user.photoUrl,
                    errorWidget: (BuildContext _, String __, Object ___) {
                      return _UserNamedCircleAvatar(user: _user, radius: radius);
                    },
                  ),
                )
              else
                _UserNamedCircleAvatar(user: _user, radius: radius),
              // if (displayActivityIndicator && _user.isActive)
              //   Positioned(
              //     right: 0.0,
              //     bottom: 0.0,
              //     child: Container(
              //       height: radius * 0.7,
              //       width: radius * 0.7,
              //       decoration: BoxDecoration(
              //           color: const Color(0xFF00FF00),
              //           border: Border.all(
              //             color: Colors.white,
              //             width: 2.0,
              //             style: BorderStyle.solid,
              //           ),
              //           shape: BoxShape.circle),
              //     ),
              //   )
              // else
              //   Container(height: 2 * radius, width: 2 * radius),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserNamedCircleAvatar extends StatelessWidget {
  const _UserNamedCircleAvatar({
    Key key,
    @required this.user,
    this.radius,
  }) : super(key: key);

  final RegisteredUserModel user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final String firstLetter = user.name.trimLeft().substring(0, 1).toUpperCase();

    return Center(
      child: Text(
        firstLetter,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius,
          fontWeight: FontWeight.bold,
          // See https://stackoverflow.com/questions/47114639/yellow-lines-under-text-widgets-in-flutter
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
