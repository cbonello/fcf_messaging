import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageServiceInterface {
  bool getDisplayIntroScreen();
  Future<bool> setDisplayIntroScreen(bool displayOnboarding);
}

class LocalStorageService implements LocalStorageServiceInterface {
  static LocalStorageService _instance;
  static SharedPreferences _preferences;

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance;
  }

  @override
  bool getDisplayIntroScreen() {
    bool displayIntroScreen;
    try {
      displayIntroScreen = _preferences.getBool('display_intro_screen') ?? true;
    } catch (_) {
      displayIntroScreen = true;
    }
    return displayIntroScreen;
  }

  @override
  Future<bool> setDisplayIntroScreen(bool displayOnboarding) {
    return _preferences.setBool('display_intro_screen', displayOnboarding);
  }
}
