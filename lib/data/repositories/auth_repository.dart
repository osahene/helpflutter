import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helpflutter/data/models/user.dart';
import 'package:helpflutter/core/api/api_service.dart';
import 'package:helpflutter/core/api/token_manager.dart';

abstract class AuthRepository {
  Future<void> registerWithPhone(
    String firstName,
    String lastName,
    String countryCode,
    String phoneNumber,
  );
  Future<void> sendLoginOtp(String countryCode, String phoneNumber);
  Future<User> verifyOtp(String countryCode, String phoneNumber, String otp);
  Future<void> logout(); // Removed token requirement, Dio handles it!
  Future<bool> isLoggedIn();
  Future<User?> getCurrentUser();
  void saveToken(String token);
  void clearToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;
  final TokenManager tokenManager = TokenManager();

  // Inject ApiService through the constructor
  AuthRepositoryImpl({required this.apiService});
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  @override
  Future<void> registerWithPhone(
    String firstName,
    String lastName,
    String countryCode,
    String phoneNumber,
  ) async {
    try {
      await apiService.register({
        'first_name': firstName,
        'last_name': lastName,
        'country_code': countryCode,
        'phone_number': phoneNumber,
      });
    } on DioException catch (e) {
      // Dio throws an exception for non-2xx status codes.
      throw Exception(
        'Registration failed: ${e.response?.statusCode} - ${e.message}',
      );
    }
  }

  @override
  Future<void> sendLoginOtp(String countryCode, String phoneNumber) async {
    try {
      await apiService.sendOtp({
        'country_code': countryCode,
        'phone_number': phoneNumber,
      });
    } on DioException catch (e) {
      throw Exception('Failed to send OTP: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<User> verifyOtp(
    String countryCode,
    String phoneNumber,
    String otp,
  ) async {
    try {
      final response = await apiService.verifyOtp({
        'country_code': countryCode,
        'phone_number': phoneNumber,
        'otp': otp,
      });

      // Dio automatically decodes JSON! Access it directly via response.data
      final data = response.data;
      final user = User.fromJson(data['user']);
      final token = data['token'];
      final refreshToken = data['refresh'];

      if (token != null && refreshToken != null) {
        await tokenManager.setTokens(token, refreshToken); // Save both tokens
      } else {
        throw Exception('Token not found in response');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));

      return user;
    } on DioException catch (_) {
      throw Exception('Invalid OTP');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiService.logout();
    } finally {
      await tokenManager.clearTokens();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    await tokenManager.loadTokens();
    final token = tokenManager.accessToken;
    return token != null && token.isNotEmpty;
  }

  @override
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString == null) return null;
    try {
      return User.fromJson(jsonDecode(userString));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }

  @override
  Future<void> clearToken() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
