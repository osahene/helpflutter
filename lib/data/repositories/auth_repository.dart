import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:helpflutter/data/models/user.dart';

abstract class AuthRepository {
  Future<User> loginWithEmail(String email, String password, bool remember);
  Future<User> registerWithEmail(
    String firstName,
    String lastName,
    String email,
    String password,
  );
  Future<User> loginWithGoogle(String idToken);
  Future<void> sendEmailOtp(String email);
  Future<void> verifyEmailOtp(String email, String otp);
  Future<void> sendPhoneOtp(String countryCode, String phoneNumber);
  Future<void> verifyPhoneOtp(String phoneNumber, String otp);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String newPassword);
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
  Future<User> loginWithEmail(
    String email,
    String password,
    bool remember,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'remember': remember,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data['user']);
      if (data['token'] != null) saveToken(data['token']);
      return user;
    } else {
      throw Exception('Login failed: ${response.statusCode}');
    }
  }

  @override
  Future<User> registerWithEmail(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data['user']);
      if (data['token'] != null) saveToken(data['token']);
      return user;
    } else {
      throw Exception('Registration failed: ${response.statusCode}');
    }
  }

  @override
  Future<User> loginWithGoogle(String idToken) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data['user']);
      if (data['token'] != null) saveToken(data['token']);
      return user;
    } else {
      throw Exception('Google login failed');
    }
  }

  @override
  Future<void> sendEmailOtp(String email) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/send-email-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200) throw Exception('Failed to send OTP');
  }

  @override
  Future<void> verifyEmailOtp(String email, String otp) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    if (response.statusCode != 200) throw Exception('Invalid OTP');
  }

  @override
  Future<void> sendPhoneOtp(String countryCode, String phoneNumber) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/send-phone-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'country_code': countryCode,
        'phone_number': phoneNumber,
      }),
    );
    if (response.statusCode != 200) throw Exception('Failed to send SMS');
  }

  @override
  Future<void> verifyPhoneOtp(String phoneNumber, String otp) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/verify-phone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phoneNumber, 'otp': otp}),
    );
    if (response.statusCode != 200) throw Exception('Invalid OTP');
  }

  @override
  Future<void> forgotPassword(String email) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200)
      throw Exception('Failed to send reset email');
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'new_password': newPassword}),
    );
    if (response.statusCode != 200) throw Exception('Failed to reset password');
  }

  @override
  Future<void> logout(String token) async {
    await client.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );
    clearToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    // Implement token check via shared_preferences or secure storage
    // For now, just return false
    return false;
  }

  @override
  Future<User?> getCurrentUser() async {
    // Implement retrieving current user from local storage
    return null;
  }

  @override
  void saveToken(String token) {
    // Save token securely (e.g., flutter_secure_storage)
  }

  @override
  void clearToken() {
    // Clear token
  }
}
