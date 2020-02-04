import 'package:fcf_messaging/src/models/user_model.dart';
import 'package:fcf_messaging/src/services/app_localizations.dart';
import 'package:flutter/material.dart';

class ContactsTab extends StatefulWidget {
  ContactsTab({Key key, @required this.authenticatedUser}) : super(key: key);

  final UserModel authenticatedUser;
  final List<UserModel> contacts = <UserModel>[];

  @override
  _ContactsTabState createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  TextEditingController _searchController;
  final List<UserModel> _filteredContacts = <UserModel>[];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredContacts.addAll(widget.contacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).canvasColor,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Icon(
                          Icons.search,
                          size: 30.0,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autocorrect: false,
                          decoration: InputDecoration(
                            hintText: context.l10n().csSearch,
                            filled: false,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          onChanged: (String newSearch) {
                            if (newSearch.trim().isEmpty) {
                              _filteredContacts
                                ..clear()
                                ..addAll(widget.contacts);
                            } else {
                              _filteredContacts
                                ..clear()
                                ..addAll(
                                  widget.contacts.where(
                                    (UserModel user) =>
                                        user.name.toLowerCase().contains(
                                              newSearch.trim().toLowerCase(),
                                            ) ||
                                        user.email.toLowerCase().contains(
                                              newSearch.trim().toLowerCase(),
                                            ),
                                  ),
                                );
                            }
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 48.0,
                      child: Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.group_add,
                              size: 30.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              context.l10n().csNewGroupButton,
                              style: const TextStyle(fontSize: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
          pinned: true,
        ),
        // SliverPadding(
        //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
        //   sliver: _filteredContacts.isNotEmpty
        //       ? SliverFixedExtentList(
        //           itemExtent: UserCard.height,
        //           delegate: SliverChildBuilderDelegate(
        //             (BuildContext context, int index) {
        //               final UserModel contact = _filteredContacts[index];
        //               return UserCard(
        //                 user: contact,
        //                 onTap: () async {
        //                   final String currentUser =
        //                       LocalStorageService.prefs.getUserEmail();
        //                   try {
        //                     final ChatModel chat =
        //                         await widget.chatRepository.getDirectChat(
        //                       currentUser,
        //                       contact.email,
        //                     );
        //                     await Navigator.push<void>(
        //                       context,
        //                       ChatView.route(
        //                         widget.userRepository,
        //                         widget.chatRepository,
        //                         chat,
        //                       ),
        //                     );
        //                     Navigator.pop(context);
        //                   } catch (exception) {
        //                     final Flushbar<Object> flushbar = FlushbarHelper.createError(
        //                       title: 'Error',
        //                       message: 'Cannot open chat',
        //                     );
        //                     unawaited(flushbar.show(context));
        //                   }
        //                 },
        //               );
        //               // ContactWidget(
        //               //   chatRepository: widget.chatRepository,
        //               //   contact: _filteredContacts[index],
        //               // );
        //             },
        //             childCount: _filteredContacts.length,
        //           ),
        //         )
        //       : SliverFixedExtentList(
        //           itemExtent: 120.0,
        //           delegate: SliverChildBuilderDelegate(
        //             (BuildContext context, int index) {
        //               return const Center(
        //                 child: Text('No results found from your contacts'),
        //               );
        //             },
        //             childCount: 1,
        //           ),
        //         ),
        // ),
      ],
    );
  }
}
