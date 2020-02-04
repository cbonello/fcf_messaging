import 'package:fcf_messaging/l10n/messages_all.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations l10n() {
    return AppLocalizations.of(this);
  }
}

class AppLocalizations {
  AppLocalizations(this.localeName) {
    current = this;
  }

  static AppLocalizations current;
  final String localeName;

  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode == null || locale.countryCode.isEmpty
        ? locale.languageCode
        : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((dynamic _) {
      Intl.defaultLocale = localeName;
      return AppLocalizations(localeName);
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get appTitle => Intl.message('FCF Messaging', name: 'appTitle');

  // Onboarding screen
  String get osSubtitle =>
      Intl.message('An open source messaging app developed with Flutter',
          name: 'osSubtitle');
  String get osButton => Intl.message('Continue', name: 'osButton');

  // Bottom navigation bar
  String get bnvChats => Intl.message('Chats', name: 'bnvChats');
  String get bnvContacts => Intl.message('Contacts', name: 'bnvContacts');
  String get bnvStatus => Intl.message('Status', name: 'bnvStatus');
  String get bnvNotifications => Intl.message('Notifications', name: 'bnvNotifications');

  // Contacts screen
  String get csSearch => Intl.message('Name or email address', name: 'csSearch');
  String get csNewGroupButton => Intl.message('New group', name: 'csNewGroupButton');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
