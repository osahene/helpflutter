import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:helpflutter/data/models/user.dart';
import 'package:helpflutter/data/models/request_history.dart';
import 'package:helpflutter/core/constants/api_service.dart';

abstract class ProfileRepository {
  Future<User> getUserProfile();
  Future<List<RequestHistory>> getRequestHistory();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService apiService;

  ProfileRepositoryImpl({required this.apiService});

  @override
  Future<User> getUserProfile() async {
    // Simulate a slight network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Dummy JSON matching your User model's expected keys
    final Map<String, dynamic> dummyUserJson = {
      'id': 'user_2026_001',
      'first_name': 'David',
      'last_name': 'Adu-Tenkorang',
      'country_code': '+233',
      'phone': '241234567',
      'profile_image_url':
          'https://ui-avatars.com/api/?name=David+Adu&background=CC2222&color=fff',
      'is_verified': true,
    };

    try {
      // This will test your User.fromJson mapping logic
      return User.fromJson(dummyUserJson);
    } catch (e) {
      // If you made a typo in the model, this will catch it
      throw 'Local Mapping Error: $e';
    }
  }
  // Future<User> getUserProfile() async {
  //   try {
  //     final response = await apiService.getUserProfile();

  //     dynamic responseData = response.data;

  //     // If the backend returns a raw string, decode it into a Map
  //     if (responseData is String) {
  //       responseData = jsonDecode(responseData);
  //     }

  //     return User.fromJson(responseData as Map<String, dynamic>);
  //   } on DioException catch (e) {
  //     throw _handleError(e);
  //   } catch (e) {
  //     // Catching standard exceptions prevents raw type errors from leaking to the UI
  //     throw 'Failed to load profile data.';
  //   }
  // }

  @override
  Future<List<RequestHistory>> getRequestHistory() async {
    try {
      final response = await apiService.getRequestHistory();
      dynamic responseData = response.data;
      // 1. If backend returns a plain string (e.g., "No history found" or unparsed JSON)
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {
          return [];
        }
      }
      if (responseData is Map) {
        if (responseData.containsKey('data') && responseData['data'] is List) {
          responseData = responseData['data'];
        } else {
          return [];
        }
      }
      // 3. Map the valid List to RequestHistory objects
      if (responseData is List) {
        return responseData
            .map(
              (json) => RequestHistory.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Unable to process history records.';
    }
  }

  // Reuse the error handler logic
  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map) {
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('message')) return data['message'].toString();
      }
    }
    return e.message ?? 'An unexpected error occurred';
  }
}
