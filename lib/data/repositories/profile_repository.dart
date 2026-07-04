import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:helpflutter/data/models/request_history.dart';
import 'package:helpflutter/core/constants/api_service.dart';

abstract class ProfileRepository {
  Future<List<RequestHistory>> getRequestHistory();
}

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService apiService;

  ProfileRepositoryImpl({required this.apiService});

  @override
  Future<List<RequestHistory>> getRequestHistory() async {
    try {
      final response = await apiService.getRequestHistory();
      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }
      if (responseData is Map<String, dynamic>) {
        final List<dynamic>? rawList = responseData['history'] is List
            ? responseData['history']
            : null;

        if (rawList != null) {
          return rawList.map((json) => RequestHistory.fromJson(json)).toList();
        }
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
