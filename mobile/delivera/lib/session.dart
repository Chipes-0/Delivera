import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static const _tokenKey = 'access_token';

  static String? _accessToken;

  static Map<String, dynamic>? _decodedToken;

  static String? get accessToken => _accessToken;

  static String? get role =>
      _decodedToken?['role']?.toString().toUpperCase();

  static bool get isAdmin => role == 'ADMIN';

  static bool get isDriver => role == 'DELIVER';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(_tokenKey);

    if (token == null || token.isEmpty) {
      _accessToken = null;
      return;
    }

    // Validar expiración
    final isExpired = JwtDecoder.isExpired(token);

    if (isExpired) {
      await prefs.remove(_tokenKey);
      _accessToken = null;

      return;
    }

    _accessToken = token;
    _decodedToken = JwtDecoder.decode(token);
  }

  static Future<void> saveToken(String token) async {
    _accessToken = token;
    _decodedToken = JwtDecoder.decode(token);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clear() async {
    _accessToken = null;
    _decodedToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static bool get isLoggedIn {
    if (_accessToken == null || _accessToken!.isEmpty) {
      return false;
    }

    try {
      return !JwtDecoder.isExpired(_accessToken!);
    } catch (_) {
      return false;
    }
  }
}