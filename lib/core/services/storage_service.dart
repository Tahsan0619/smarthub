import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth
  static Future<void> saveUser(String userJson) async {
    await _prefs.setString('current_user', userJson);
  }

  static String? getUser() {
    return _prefs.getString('current_user');
  }

  static Future<void> clearUser() async {
    await _prefs.remove('current_user');
  }

  // Generic storage
  static Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }
}
