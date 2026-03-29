import 'package:helpflutter/data/models/alert.dart';
import 'package:geolocator/geolocator.dart';
import 'package:helpflutter/core/api/api_service.dart';
import 'package:dio/dio.dart';

abstract class AlertRepository {
  /// Send an alert with situation details and optional location data.
  Future<Alert> sendAlert({
    required String situation,
    required bool includeLocation,
  });
}

class AlertRepositoryImpl implements AlertRepository {
  final ApiService apiService;

  AlertRepositoryImpl({required this.apiService});

  @override
  Future<Alert> sendAlert({
    required String situation,
    required bool includeLocation,
  }) async {
    // 1. Get current location if requested
    Position? position;
    if (includeLocation) {
      try {
        position = await _getCurrentLocation();
      } catch (e) {
        // Log error but perhaps continue without location if the situation is dire
        print('Location error: $e');
      }
    }

    // 2. Prepare the request payload
    // Note: Ensure these keys match what your Django EmergencyActionView expects!
    final Map<String, dynamic> payload = {
      'situation': situation,
      'include_location': includeLocation,
      'latitude': position?.latitude,
      'longitude': position?.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 3. Send to backend via ApiService (Dio)
    try {
      final response = await apiService.triggerAlert(payload);

      // Dio automatically decodes the JSON body into response.data
      return Alert.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to trigger emergency alert: ${e.response?.statusCode} ${e.message}',
      );
    }
  }

  /// Helper to handle Location Permissions and Fetching
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
