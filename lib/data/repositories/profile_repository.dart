import 'package:dio/dio.dart';
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
    try {
      final response = await apiService.getUserProfile();
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<RequestHistory>> getRequestHistory() async {
    try {
      final response = await apiService.getRequestHistory();
      final List<dynamic> data = response.data;

      // Map the JSON list to a list of RequestHistory objects
      return data.map((json) => RequestHistory.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Reuse the error handler logic from AuthRepository
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
