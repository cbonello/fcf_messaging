import 'package:fcf_messaging/constants.dart';
import 'package:fcf_messaging/src/services/app_localizations.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AssetImage logo;

  @override
  void initState() {
    logo = const AssetImage(APP_ASSET_LOGO);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(logo, context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FractionallySizedBox(widthFactor: 0.5, child: Image(image: logo)),
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(seconds: 1),
                child: Text(
                  context.l10n().appTitle,
                  style: Theme.of(context).textTheme.title,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
