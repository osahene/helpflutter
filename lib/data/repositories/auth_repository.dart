import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:helpflutter/data/models/user.dart';

abstract class AuthRepository {
  Future<void> registerWithPhone(
    String firstName,
    String lastName,
    String countryCode,
    String phoneNumber,
  );
  Future<void> sendLoginOtp(String countryCode, String phoneNumber);
  Future<User> verifyOtp(String countryCode, String phoneNumber, String otp);
  Future<void> logout(String token);
  Future<bool> isLoggedIn();
  Future<User?> getCurrentUser();
  void saveToken(String token);
  void clearToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final String baseUrl;
  final http.Client client;

  AuthRepositoryImpl({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  @override
  Future<void> registerWithPhone(
    String firstName,
    String lastName,
    String countryCode,
    String phoneNumber,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/account/user-register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'country_code': countryCode,
        'phone_number': phoneNumber,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Registration failed: ${response.statusCode}');
    }
  }

  @override
  Future<void> sendLoginOtp(String countryCode, String phoneNumber) async {
    final response = await client.post(
      Uri.parse('$baseUrl/account/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'country_code': countryCode,
        'phone_number': phoneNumber,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send OTP');
    }
  }

  @override
  Future<User> verifyOtp(
    String countryCode,
    String phoneNumber,
    String otp,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/account/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'country_code': countryCode,
        'phone_number': phoneNumber,
        'otp': otp,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data['user']);
      if (data['token'] != null) saveToken(data['token']);
      return user;
    } else {
      throw Exception('Invalid OTP');
    }
  }

  @override
  Future<void> logout(String token) async {
    await client.post(
      Uri.parse('$baseUrl/account/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );
    clearToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    // Implement with secure storage
    return false;
  }

  @override
  Future<User?> getCurrentUser() async {
    // Implement retrieval
    return null;
  }

  @override
  void saveToken(String token) {
    // Save token securely
  }

  @override
  void clearToken() {
    // Clear token
  }
}
