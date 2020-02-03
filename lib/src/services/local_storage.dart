import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorageServiceInterface {
  bool getDisplayOnboarding();
  Future<bool> setDisplayOnboarding(bool displayOnboarding);
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
  bool getDisplayOnboarding() {
    bool displayOnboarding;
    try {
      displayOnboarding = _preferences.getBool('display_onboarding') ?? true;
    } catch (_) {
      displayOnboarding = true;
    }
    return displayOnboarding;
  }

  @override
  Future<bool> setDisplayOnboarding(bool displayOnboarding) {
    return _preferences.setBool('display_onboarding', displayOnboarding);
  }
}
