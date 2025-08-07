import 'package:shared_preferences/shared_preferences.dart';

class FirstLoginHelper {
  static const String _hasLoggedInKey = 'hasLoggedInBefore';

  static Future<bool> hasLoggedInBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasLoggedInKey) ?? false;
  }

  static Future<void> setHasLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasLoggedInKey, true);
  }

  static Future<void> clearHasLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasLoggedInKey);
  }
}
