import 'package:helpflutter/data/models/live_report.dart';

abstract class LiveReportRepository {
  Future<bool> sendReport(LiveReport report);
}

class MockLiveReportRepository implements LiveReportRepository {
  @override
  Future<bool> sendReport(LiveReport report) async {
    await Future.delayed(const Duration(seconds: 2));
    // Simulate success
    return true;
  }
}
