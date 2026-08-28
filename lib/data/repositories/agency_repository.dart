import 'package:helpflutter/core/constants/api_service.dart';
import 'package:helpflutter/data/models/agency.dart';

abstract class AgencyRepository {
  /// The active government emergency agencies (police/fire/ambulance/etc.)
  /// a user can send a live report to.
  Future<List<Agency>> getAgencies();
}

class AgencyRepositoryImpl implements AgencyRepository {
  final ApiService apiService;

  AgencyRepositoryImpl({required this.apiService});

  @override
  Future<List<Agency>> getAgencies() async {
    final response = await apiService.getAgencies();
    final data = response.data as List<dynamic>;
    return data
        .map((json) => Agency.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
