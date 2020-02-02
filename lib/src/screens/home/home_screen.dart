import 'package:fcf_messaging/src/blocs/authentication/authentication_bloc.dart';
import 'package:fcf_messaging/src/blocs/chats/chats_bloc.dart';
import 'package:fcf_messaging/src/blocs/tab/tab_bloc.dart';
import 'package:fcf_messaging/src/models/app_tabs_model.dart';
import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/repositories/cache_repository.dart';
import 'package:fcf_messaging/src/screens/home/tabs/tabs.dart';
import 'package:fcf_messaging/src/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key, @required this.authenticatedUser}) : super(key: key);

  final UserModel authenticatedUser;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final TabBloc tabBloc = context.bloc<TabBloc>();

    return BlocBuilder<TabBloc, AppTabModel>(
      builder: (BuildContext context, AppTabModel activeTab) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () {
                  context.bloc<AuthenticationBloc>().add(SignedOut());
                },
              )
            ],
          ),
          body: IndexedStack(
            index: AppTabModel.values.indexOf(activeTab),
            children: <Widget>[
              BlocProvider<ChatsBloc>(
                create: (BuildContext context) => ChatsBloc(
                  user: widget.authenticatedUser,
                  cache: CacheRepository(user: widget.authenticatedUser)..init(),
                ),
                child: ChatsTab(authenticatedUser: widget.authenticatedUser),
              ),
              ContactsTab(authenticatedUser: widget.authenticatedUser),
              StatusTab(authenticatedUser: widget.authenticatedUser),
              NotificationsTab(authenticatedUser: widget.authenticatedUser),
            ],
          ),
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
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          title: Text(context.l10n().bnvChats),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          title: Text(context.l10n().bnvContacts),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          title: Text(context.l10n().bnvStatus),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          title: Text(context.l10n().bnvNotifications),
        ),
      ],
    );
  }
}
