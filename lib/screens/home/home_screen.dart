import 'package:fcf_messaging/blocs/authentication/authentication_bloc.dart';
import 'package:fcf_messaging/blocs/tab/tab_bloc.dart';
import 'package:fcf_messaging/models/app_tabs_model.dart';
import 'package:fcf_messaging/models/user_model.dart';
import 'package:fcf_messaging/screens/home/tabs/tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _TabDescriptor {
  const _TabDescriptor({
    @required this.iconData,
    @required this.title,
    @required this.builder,
  });

  final IconData iconData;
  final String title;
  final Function(UserModel) builder;
}

final List<_TabDescriptor> _tabs = <_TabDescriptor>[
  _TabDescriptor(
    iconData: Icons.chat,
    title: 'Chats',
    builder: (UserModel user) => ChatsTab(authenticatedUser: user),
  ),
  _TabDescriptor(
    iconData: Icons.person,
    title: 'Contacts',
    builder: (UserModel user) => ContactsTab(authenticatedUser: user),
  ),
  _TabDescriptor(
    iconData: Icons.info,
    title: 'Status',
    builder: (UserModel user) => StatusTab(authenticatedUser: user),
  ),
  _TabDescriptor(
    iconData: Icons.notifications,
    title: 'Notifications',
    builder: (UserModel user) => NotificationsTab(authenticatedUser: user),
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key, @required this.authenticatedUser}) : super(key: key);

  final UserModel authenticatedUser;

  // static Route<dynamic> route() {
  //   return MaterialPageRoute<dynamic>(
  //     builder: (BuildContext context) => HomeScreen(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final TabBloc tabBloc = BlocProvider.of<TabBloc>(context);
    assert(_tabs.length == AppTabModel.values.length);

    return BlocBuilder<TabBloc, AppTabModel>(
      builder: (BuildContext context, AppTabModel activeTab) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  BlocProvider.of<AuthenticationBloc>(context).add(SignedOut());
                },
              )
            ],
          ),
          body: _tabs[AppTabModel.values.indexOf(activeTab)].builder(authenticatedUser),
          bottomNavigationBar: _BottomNavbar(
            activeTab: activeTab,
            onTabSelected: (AppTabModel tab) => tabBloc.add(UpdateTab(tab)),
          ),
        );
      },
    );
  }
}

class _BottomNavbar extends StatelessWidget {
  const _BottomNavbar({
    Key key,
    @required this.activeTab,
    @required this.onTabSelected,
  }) : super(key: key);

  final AppTabModel activeTab;
  final Function(AppTabModel) onTabSelected;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.green[600],
      unselectedItemColor: Colors.grey[400],
      currentIndex: AppTabModel.values.indexOf(activeTab),
      onTap: (int index) => onTabSelected(AppTabModel.values[index]),
      showUnselectedLabels: true,
      items: _tabs.map((_TabDescriptor desc) {
        return BottomNavigationBarItem(
          icon: Icon(desc.iconData),
          title: Text(desc.title),
        );
      }).toList(),
    );
  }
}
