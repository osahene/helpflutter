import 'package:dio/dio.dart';
import 'package:helpflutter/data/models/user.dart';
import 'package:helpflutter/core/api/api_service.dart';

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

  // Inject ApiService through the constructor
  AuthRepositoryImpl({required this.apiService});

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

      if (data['token'] != null) {
        saveToken(data['token']);
      }

      return user;
    } on DioException catch (_) {
      throw Exception('Invalid OTP');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // You no longer need to pass the token manually!
      // Your DioClient interceptor attaches it automatically.
      await apiService.logout();
    } catch (e) {
      // Handle or log error
    } finally {
      clearToken();
    }
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
    // Save token securely (e.g., flutter_secure_storage)
  }

  @override
  void clearToken() {
    // Clear token
  }
}
