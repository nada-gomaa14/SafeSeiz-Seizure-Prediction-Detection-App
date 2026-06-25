import 'package:shared_preferences/shared_preferences.dart';

class SettingsPreferences {
  static const _medReminders = 'med_reminders';

  static Future<bool> getMedReminders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_medReminders) ?? false;
  }

  static Future<void> setMedReminders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_medReminders, value);
  }
}