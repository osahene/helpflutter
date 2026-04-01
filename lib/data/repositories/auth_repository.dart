import 'package:dio/dio.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/core/constants/api_client.dart';
import 'package:helpflutter/core/constants/secure_storage.dart';
import 'package:helpflutter/data/models/user.dart';

class AuthRepository {
  final Dio _dio = ApiClient.dio;

  Future<void> register({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String phoneNumber,
  }) async {
    try {
      await _dio.post(
        AppConstants.register,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'country_code': countryCode,
          'phone_number': phoneNumber,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> sendOtp({
    required String countryCode,
    required String phoneNumber,
  }) async {
    try {
      await _dio.post(
        AppConstants.sendOtp,
        data: {'country_code': countryCode, 'phone_number': phoneNumber},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<({User user, String accessToken, String refreshToken})> verifyOtp({
    required String countryCode,
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.verifyOtp,
        data: {
          'country_code': countryCode,
          'phone_number': phoneNumber,
          'otp': otp,
        },
      );
      final data = response.data;
      final user = User.fromJson(data['user']);
      final accessToken = data['token'] as String;
      final refreshToken = data['refresh'] as String;
      return (user: user, accessToken: accessToken, refreshToken: refreshToken);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post(AppConstants.logout, data: {'refresh': refreshToken});
      await SecureStorage.clearTokens();
    } on DioException catch (e) {
      // Even if logout fails, clear tokens locally
      await SecureStorage.clearTokens();
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('error')) {
        return data['error'];
      }
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Something went wrong';
    }
    return e.message ?? 'Network error';
  }
}
