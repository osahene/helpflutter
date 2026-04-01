import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/core/constants/api_client.dart';

class EmergencyRepository {
  final Dio _dio = ApiClient.dio;

  Future<void> triggerAlert({
    required String alertType,
    required Position location,
  }) async {
    try {
      await _dio.post(
        AppConstants.triggerAlert,
        data: {
          'alertType': alertType,
          'location': {
            'latitude': location.latitude,
            'longitude': location.longitude,
          },
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('error')) return data['error'];
      if (data is Map && data.containsKey('message')) return data['message'];
    }
    return e.message ?? 'Network error';
  }
}
