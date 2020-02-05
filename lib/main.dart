// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview/device_preview.dart';
import 'package:fcf_messaging/app.dart';
import 'package:fcf_messaging/src/blocs/authentication/authentication_bloc.dart';
import 'package:fcf_messaging/src/blocs/simple_bloc_delegate.dart';
import 'package:fcf_messaging/src/services/service_locator.dart';
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

  runApp(
    BlocProvider<AuthenticationBloc>(
      create: (BuildContext context) {
        return AuthenticationBloc(
          firebaseAnalytics: firebaseAnalytics,
        )..add(AppStarted());
      },
      child: isInDebugMode
          ? DevicePreview(
              builder: (BuildContext context) => App(),
            )
          : App(),
    ),
  );
}
