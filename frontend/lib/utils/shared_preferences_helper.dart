import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _tokenKey = "token";
  static const String _macAddressKey = "macAddress";

  /// Save Token (After Login/Signup)
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Retrieve Token (For API Calls)
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Remove Token (On Logout)
  static Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Save MAC Address (After Login/Signup)
  static Future<void> saveMacAddress(String macAddress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_macAddressKey, macAddress);
  }

  /// Retrieve MAC Address (For API Calls)
  static Future<String?> getMacAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_macAddressKey);
  }

  /// Clear All Data (When Needed)
  static Future<void> clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
