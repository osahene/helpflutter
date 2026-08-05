import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/data/models/user.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveUser(User user) async {
    await _storage.write(
      key: AppConstants.userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  static Future<User?> getCachedUser() async {
    final userJson = await _storage.read(key: AppConstants.userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    await _storage.delete(key: AppConstants.userKey);
    await _storage.write(key: AppConstants.isLoggedInKey, value: 'false');
  }

  static Future<void> setLoggedIn(bool value) async {
    await _storage.write(
      key: AppConstants.isLoggedInKey,
      value: value.toString(),
    );
  }

  static Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: AppConstants.isLoggedInKey);
    return value == 'true';
  }
}
