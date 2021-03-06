import 'package:fcf_messaging/constants.dart';
import 'package:fcf_messaging/src/blocs/authentication/authentication_bloc.dart';
import 'package:fcf_messaging/src/screens/widgets/horizontal_line.dart';
import 'package:fcf_messaging/src/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthenticationBloc authenticationBloc = context.bloc<AuthenticationBloc>();

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: FractionallySizedBox(
            widthFactor: 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image(height: 120.0, fit: BoxFit.fill, image: AssetImage(APP_ASSET_LOGO)),
                const SizedBox(height: 10.0),
                Text(
                  context.l10n().appTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32.0),
                ),
                const SizedBox(height: 40.0),
                Text(
                  context.l10n().isSubtitle,
                  style: const TextStyle(fontSize: 28.0),
                  textAlign: TextAlign.center,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 25.0),
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Row(
                      children: const <Widget>[
                        Expanded(child: HorizontalLine()),
                      ],
                    ),
                  ),
                ),
                Text(
                  context.l10n().isDescription,
                  style: const TextStyle(fontSize: 28.0),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40.0),
                RaisedButton(
                  color: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  padding: const EdgeInsets.all(25.0),
                  onPressed: () => authenticationBloc.add(StartAuthentication()),
                  child: Text(
                    context.l10n().isButton,
                    style: const TextStyle(color: Colors.white, fontSize: 26.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
