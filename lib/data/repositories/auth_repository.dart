import 'package:dio/dio.dart';
import 'package:helpflutter/core/constants/api_service.dart';
import 'package:helpflutter/core/constants/secure_storage.dart';
import 'package:helpflutter/data/models/user.dart';

abstract class AuthRepository {
  Future<void> register({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String phoneNumber,
    required bool agreedToTerms,
  });

  Future<void> sendOtp({
    required String countryCode,
    required String phoneNumber,
  });

  Future<({User user, String token, String refresh})> verifyOtp({
    required String countryCode,
    required String phoneNumber,
    required String otp,
  });

  Future<void> logout(String refreshToken);

  Future<User> getProfile();
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;

  AuthRepositoryImpl({required this.apiService});

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String phoneNumber,
    required bool agreedToTerms,
  }) async {
    try {
      await apiService.register({
        'first_name': firstName,
        'last_name': lastName,
        'country_code': countryCode,
        'phone_number': phoneNumber,
        'agree_to_terms': agreedToTerms,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> sendOtp({
    required String countryCode,
    required String phoneNumber,
  }) async {
    try {
      await apiService.sendOtp({
        'country_code': countryCode,
        'phone_number': phoneNumber,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<({User user, String token, String refresh})> verifyOtp({
    required String countryCode,
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await apiService.verifyOtp({
        'country_code': countryCode,
        'phone_number': phoneNumber,
        'otp': otp,
      });

      final data = response.data;
      final Map<String, dynamic> actualData = (data is List) ? data[0] : data;

      return (
        user: User.fromJson(actualData['user']),
        token: actualData['token'] as String,
        refresh: actualData['refresh'] as String,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<User> getProfile() async {
    try {
      final response = await apiService.getUserProfile();
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await apiService.logout();
      await SecureStorage.clearSession();
    } on DioException catch (e) {
      await SecureStorage.clearSession();
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('detail')) return data['detail'].toString();
      }
    }
    return e.message ?? 'An unexpected error occurred';
  }
}
