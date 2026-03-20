import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  // Use shared_preferences (or flutter_secure_storage for production)
  Future<void> setTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // Check if access token is expired (using jwt_decoder)
  bool isAccessTokenExpired() {
    if (_accessToken == null) return true;
    try {
      final parts = _accessToken!.split('.');
      if (parts.length != 3) return true;
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload['exp'];
      if (exp == null) return true;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp < now;
    } catch (e) {
      return true;
    }
  }
}
