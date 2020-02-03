import 'package:fcf_messaging/src/blocs/authentication/authentication_bloc.dart';
import 'package:fcf_messaging/src/blocs/tab/tab_bloc.dart';
import 'package:fcf_messaging/src/models/app_tabs_model.dart';
import 'package:fcf_messaging/src/repositories/hive/hive_repository.dart';
import 'package:fcf_messaging/src/screens/home/home_screen.dart';
import 'package:fcf_messaging/src/screens/onboarding_screen.dart';
import 'package:fcf_messaging/src/screens/signin/signin_screen.dart';
import 'package:fcf_messaging/src/screens/splash_screen.dart';
import 'package:fcf_messaging/src/services/app_localizations.dart';
import 'package:fcf_messaging/src/services/service_locator.dart';
import 'package:fcf_messaging/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Future<void> dispose() async {
    final HiveRepository hiveService = locator<HiveRepository>();
    await hiveService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (BuildContext context) => context.l10n().appTitle,
      theme: AppTheme.theme(Brightness.light),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[Locale('en', 'US'), Locale('fr', 'FR')],
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (BuildContext context, AuthenticationState state) {
          if (state is Unauthenticated) {
            return SigninScreen();
          }
          if (state is Authenticated) {
            return BlocProvider<TabBloc>(
              create: (BuildContext context) => TabBloc(initialTab: AppTabModel.CHATS),
              child: HomeScreen(authenticatedUser: state.user),
            );
          }
          if (state is DisplayOnboarding) {
            return OnboardingScreen(user: state.user);
          }
          return SplashScreen();
        },
      ),
    );
  }
}
