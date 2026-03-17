import 'dart:convert';
import 'package:helpflutter/data/models/alert.dart';
import 'package:http/http.dart' as http; // Add http to pubspec.yaml
import 'package:geolocator/geolocator.dart'; // Add geolocator

abstract class AlertRepository {
  /// Send an alert to the specified contacts (or all accepted contacts if contactIds is null).
  /// Optionally includes the current location.
  /// Returns the created Alert object.
  Future<Alert> sendAlert({
    required String situation,
    required bool includeLocation,
  });
}

class AlertRepositoryImpl implements AlertRepository {
  final String baseUrl; // Your backend API base URL
  final http.Client httpClient;

  AlertRepositoryImpl({required this.baseUrl, http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();
  @override
  Future<Alert> sendAlert({
    required String situation,
    required bool includeLocation,
    String? customMessage,
    List<String>? contactIds,
  }) async {
    // 1. Get current location if requested
    Position? position;
    if (includeLocation) {
      position = await _getCurrentLocation();
    }

    // 2. Prepare the request payload
    final Map<String, dynamic> payload = {
      'situation': situation,
      'includeLocation': includeLocation,
      'location': position != null
          ? {'latitude': position.latitude, 'longitude': position.longitude}
          : null,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 3. Send to backend (adjust endpoint as needed)
    final response = await httpClient.post(
      Uri.parse('$baseUrl/alerts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Alert.fromJson(data);
    } else {
      throw Exception('Failed to send alert: ${response.statusCode}');
    }
  }

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

    return await Geolocator.getCurrentPosition();
  }
}
