import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _tokenKey = 'access_token';

  static String? accessToken;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    accessToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clear() async {
    accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static bool get isLoggedIn =>
      accessToken != null && accessToken!.isNotEmpty;
}
