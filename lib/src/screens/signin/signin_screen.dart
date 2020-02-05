import 'package:fcf_messaging/constants.dart';
import 'package:fcf_messaging/src/blocs/signin/signin_bloc.dart';
import 'package:fcf_messaging/src/blocs/signup/signup_bloc.dart';
import 'package:fcf_messaging/src/screens/signin/signin_form.dart';
import 'package:fcf_messaging/src/screens/signin/signup_form.dart';
import 'package:fcf_messaging/src/screens/signin/widgets/tab_bar.dart';
import 'package:fcf_messaging/src/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SigninScreen extends StatefulWidget {
  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  PageController _pageController;
  Color left = Colors.black, right = Colors.white;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey,
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: SingleChildScrollView(
            child: GestureDetector(
              // See https://flutter360.dev/dismiss-keyboard-form-lose-focus/
              onTap: () {
                final FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: Container(
                color: Colors.transparent,
                width: MediaQuery.of(context).size.width,
                height: 800.0,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 50.0),
                          child: Image(
                            height: 120.0,
                            fit: BoxFit.fill,
                            image: AssetImage(APP_ASSET_LOGO),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          context.l10n().appTitle,
                          style: Theme.of(context).textTheme.title,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: AppTabBar(
                        pageController: _pageController,
                        left: left,
                        right: right,
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        reverse: true,
                        onPageChanged: (int i) {
                          if (i == 0) {
                            setState(() {
                              right = Colors.white;
                              left = Colors.black;
                            });
                          } else if (i == 1) {
                            setState(() {
                              right = Colors.black;
                              left = Colors.white;
                            });
                          }
                        },
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(
                                left: 80, top: 23.0, right: 80, bottom: 32.0),
                            child: Card(
                              elevation: 2.0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: BlocProvider<SignInBloc>(
                                create: (BuildContext context) => SignInBloc(),
                                child: SigninForm(),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                left: 80, top: 23.0, right: 80, bottom: 32.0),
                            child: Card(
                              elevation: 2.0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: BlocProvider<SignUpBloc>(
                                create: (BuildContext context) => SignUpBloc(),
                                child: SignupForm(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
