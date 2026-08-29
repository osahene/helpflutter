import 'package:helpflutter/core/constants/api_service.dart';
import 'package:helpflutter/data/models/incoming_alert.dart';

abstract class IncomingAlertRepository {
  /// The detail of an incoming emergency alert this device was notified
  /// about (via a `type: incoming_alert` push), fetched by emergency id.
  Future<IncomingAlert> getIncomingAlert(String emergencyId);

  /// Marks an alert as seen/verified using its short [IncomingAlert.alertCode].
  /// Reuses the same `verify-emergency` endpoint the rest of the app already
  /// calls to verify an alert code.
  Future<void> verifyAlert(String alertCode);
}

class IncomingAlertRepositoryImpl implements IncomingAlertRepository {
  final ApiService apiService;

  IncomingAlertRepositoryImpl({required this.apiService});

  @override
  Future<IncomingAlert> getIncomingAlert(String emergencyId) async {
    final response = await apiService.getIncomingAlert(emergencyId);
    return IncomingAlert.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> verifyAlert(String alertCode) async {
    await apiService.verifyEmergency(alertCode);
  }
}
