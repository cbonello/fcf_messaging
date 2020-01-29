import 'package:fcf_messaging/blocs/signin/signin_bloc.dart';
import 'package:fcf_messaging/blocs/signup/signup_bloc.dart';
import 'package:fcf_messaging/screens/screens/signin/signin_form.dart';
import 'package:fcf_messaging/screens/screens/signin/signup_form.dart';
import 'package:fcf_messaging/screens/screens/signin/tabbar.dart';
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
    return Scaffold(
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
              // MediaQuery.of(context).size.height >= 775.0
              //     ? MediaQuery.of(context).size.height
              //     : 775.0,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 50.0),
                    child: Image(
                      // width: 250.0,
                      height: 191.0,
                      fit: BoxFit.fill,
                      image: AssetImage('assets/images/app_logo.png'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Tabbar(
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
    );
  }
}
