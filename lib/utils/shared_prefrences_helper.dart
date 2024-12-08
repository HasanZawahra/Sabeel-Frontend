import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static Future<SharedPreferences> _getInstance() async {
    return SharedPreferences.getInstance();
  }

  static Future<bool> isVerified() async {
    final prefs = await _getInstance();
    return prefs.getBool('isVerified') ?? false;
  }

  static Future<void> setVerified(bool isVerified) async {
    final prefs = await _getInstance();
    await prefs.setBool('isVerified', isVerified);
  }
}
