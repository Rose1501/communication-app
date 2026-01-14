import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _firstLaunchKey = 'first_launch';
  
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }
  
  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
  }
}