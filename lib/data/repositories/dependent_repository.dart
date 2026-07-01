import 'package:helpflutter/data/models/dependent.dart';
import 'package:helpflutter/core/constants/api_service.dart';
import 'package:dio/dio.dart';

abstract class DependentRepository {
  Future<List<Dependent>> getDependents();
  Future<void> updateDependentStatus(
    String dependentId,
    DependentStatus status,
  );
}

class DependentRepositoryImpl implements DependentRepository {
  final ApiService apiService;

  DependentRepositoryImpl({required this.apiService});

  @override
  Future<List<Dependent>> getDependents() async {
    try {
      final response = await apiService.getMyDependants();
      final dynamic data = response.data;

      if (data is Map<String, dynamic> && data['data'] is List) {
        final List<dynamic> rawList = data['data'];
        return rawList.map((json) => Dependent.fromJson(json)).toList();
      }

      if (data is List) {
        return data.map((json) => Dependent.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception('Server Error: ${e.response?.statusCode}');
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> updateDependentStatus(
    String dependentId,
    DependentStatus status,
  ) async {
    try {
      final payload = {'id': dependentId, 'status': status.name};
      if (status == DependentStatus.approved) {
        await apiService.approveDependant(payload);
      } else if (status == DependentStatus.rejected) {
        await apiService.rejectDependant(payload);
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to update dependent status: ${e.response?.data ?? e.message}',
      );
    }
  }
}
