import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:helpflutter/core/constants/api_service.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/data/models/live_report.dart';
import 'package:mime/mime.dart';

abstract class LiveReportRepository {
  /// Sends the report and returns the backend emergency id.
  Future<String> sendReport(LiveReport report);
}

class LiveReportRepositoryImpl implements LiveReportRepository {
  final ApiService apiService;

  LiveReportRepositoryImpl({required this.apiService});

  @override
  Future<String> sendReport(LiveReport report) async {
    final position = await _getCurrentLocation();

    final formData = FormData.fromMap({
      'situation': AppConstants.situationToAlertType[report.situation] ??
          'other',
      'latitude': position.latitude,
      'longitude': position.longitude,
      if (report.message != null && report.message!.trim().isNotEmpty)
        'message': report.message!.trim(),
      'agency_ids': report.agencyIds,
    });

    for (final attachment in report.media) {
      final mimeType =
          lookupMimeType(attachment.path) ?? _fallbackMimeType(attachment.type);
      final parts = mimeType.split('/');
      formData.files.add(
        MapEntry(
          'media',
          await MultipartFile.fromFile(
            attachment.path,
            contentType: DioMediaType(parts[0], parts[1]),
          ),
        ),
      );
    }

    try {
      final response = await apiService.sendLiveReport(formData);
      return response.data['id'] as String;
    } on DioException catch (e) {
      final serverError = e.response?.data is Map
          ? (e.response?.data['error'] ?? e.response?.data['detail'])
          : null;
      throw Exception(serverError ?? 'Failed to send live report: ${e.message}');
    }
  }

  String _fallbackMimeType(String type) {
    switch (type) {
      case 'image':
        return 'image/jpeg';
      case 'video':
        return 'video/mp4';
      case 'audio':
        return 'audio/mp4';
      default:
        return 'application/octet-stream';
    }
  }

  /// Mirrors AlertRepositoryImpl's location handling — a live report is
  /// meaningless to a responding agency without a location, so this throws
  /// rather than silently sending without one.
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

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      ),
    ).catchError((e) async {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;
      throw e;
    });
  }
}

class MockLiveReportRepository implements LiveReportRepository {
  @override
  Future<String> sendReport(LiveReport report) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'mock-emergency-id';
  }
}
