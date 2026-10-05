import 'package:flutter/foundation.dart';
import 'package:helpflutter/data/models/alert.dart';
import 'package:geolocator/geolocator.dart';
import 'package:helpflutter/core/constants/api_service.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:dio/dio.dart';

/// An alert that could not be sent at all — [message] is plain language,
/// safe to show the user as-is (AlertConfirmationScreen's AlertFailedSheet).
class AlertSendException implements Exception {
  final String message;
  const AlertSendException(this.message);

  @override
  String toString() => message;
}

abstract class AlertRepository {
  /// Send an alert with situation details and optional location data.
  ///
  /// [clientAlertId] identifies one alert across retries — the backend
  /// returns the existing alert instead of creating a duplicate when the
  /// same id is sent again (e.g. the first attempt actually got through
  /// but its response was lost).
  Future<Alert> sendAlert({
    required String situation,
    required bool includeLocation,
    String? clientAlertId,
  });
}

class AlertRepositoryImpl implements AlertRepository {
  final ApiService apiService;

  AlertRepositoryImpl({required this.apiService});

  @override
  Future<Alert> sendAlert({
    required String situation,
    required bool includeLocation,
    String? clientAlertId,
  }) async {
    // 1. Get current location. The whole point of an alert is telling
    //    contacts where the user is, and the backend rejects an alert
    //    without one — so say exactly why here instead of sending a
    //    request that's guaranteed to fail.
    Position? position;
    String? locationProblem;
    if (includeLocation) {
      try {
        position = await _getCurrentLocation();
      } on AlertSendException catch (e) {
        locationProblem = e.message;
      } catch (e) {
        debugPrint('Location error caught: $e');
      }
      if (position == null) {
        throw AlertSendException(
          locationProblem ??
              "We couldn't find your location, so your contacts can't be told "
                  'where you are. Move to an open area and try again.',
        );
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
      'clientAlertId': ?clientAlertId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 4. Send to backend via ApiService (Dio)
    try {
      final response = await apiService.triggerAlert(payload);
      return Alert.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Alert request failed: ${e.response?.statusCode} ${e.message}');
      throw AlertSendException(_describe(e));
    }
  }

  static String _describe(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      // The backend's own explanation, e.g. no approved contacts set up
      // for this situation — already written for users.
      final serverMessage = data['error'] ?? data['detail'];
      if (serverMessage is String && serverMessage.isNotEmpty) {
        return serverMessage;
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionError:
        return 'No internet connection, so your alert could not be sent.';
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The connection is too slow and your alert could not be sent.';
      default:
        return 'Your alert could not be sent because of a problem on our side.';
    }
  }

  /// Helper to handle Location Permissions and Fetching
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const AlertSendException(
        'Your location is turned off. Turn on location so your contacts can '
        'see where you are, then try again.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const AlertSendException(
          'Location permission is needed so your contacts can see where you '
          'are. Allow it and try again.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const AlertSendException(
        'Location permission is blocked for this app. Allow it in your '
        "phone's settings so your contacts can see where you are.",
      );
    }

    // Fast, precise fix first; indoors that often times out, so fall back to
    // the last known position, then to a coarser fix given more time.
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    }
  }
}
