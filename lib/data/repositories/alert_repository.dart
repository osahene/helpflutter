import 'package:flutter/foundation.dart';
import 'package:helpflutter/data/models/alert.dart';
import 'package:geolocator/geolocator.dart';
import 'package:helpflutter/core/constants/api_service.dart';
import 'package:helpflutter/core/constants/constants.dart';
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
        debugPrint('Location error caught: $e');
      }
    }

    // 2. Format the situation string for the backend payload
    final String formattedAlertType =
        AppConstants.situationToAlertType[situation] ?? 'other';

    // 3. Prepare the request payload
    final Map<String, dynamic> payload = {
      'alertType': formattedAlertType,
      'include_location': includeLocation,
      'location': position != null
          ? {'latitude': position.latitude, 'longitude': position.longitude}
          : null,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 4. Send to backend via ApiService (Dio)
    try {
      final response = await apiService.triggerAlert(payload);
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
      throw Exception('Location services are disabled on the device.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions were denied by the user.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Change this in settings.',
      );
    }

    // Added a time limit fallback in case high accuracy takes too long indoors
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      ),
    ).catchError((e) async {
      // If high accuracy fails/times out, try grabbing the last known location
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;
      throw e;
    });
  }
}
