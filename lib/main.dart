// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fcf_messaging/blocs/authentication/authentication_bloc.dart';
import 'package:fcf_messaging/blocs/simple_bloc_delegate.dart';
import 'package:fcf_messaging/blocs/tab/tab_bloc.dart';
import 'package:fcf_messaging/locator.dart';
import 'package:fcf_messaging/models/app_tabs_model.dart';
import 'package:fcf_messaging/screens/home/home_screen.dart';
import 'package:fcf_messaging/screens/signin/signin_screen.dart';
import 'package:fcf_messaging/screens/splash_screen.dart';
import 'package:fcf_messaging/theme.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_lumberdash/firebase_lumberdash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lumberdash/lumberdash.dart';

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // putLumberdashToWork(
  //   withClients: <LumberdashClient>[
  //     FirebaseLumberdash(
  //       firebaseAnalyticsClient: FirebaseAnalytics(),
  //       environment: 'development',
  //       releaseVersion: '1.0.0+1',
  //     ),
  //   ],
  // );
  await setupLocator();

  runMessagingApp();
}

void runMessagingApp() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics();

  runApp(BlocProvider<AuthenticationBloc>(
    create: (BuildContext context) {
      return AuthenticationBloc(
        firebaseAnalytics: firebaseAnalytics,
      )..add(AppStarted());
    },
    child: App(),
  ));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.theme(Brightness.light),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (BuildContext context, AuthenticationState state) {
          if (state is Unauthenticated) {
            return SigninScreen();
          }
          if (state is Authenticated) {
            return BlocProvider<TabBloc>(
              create: (BuildContext context) {
                return TabBloc(initialTab: AppTabModel.CHATS);
              },
              child: HomeScreen(authenticatedUser: state.user),
            );
          }
          return SplashScreen();
        },
      ),
    );
  }
}
