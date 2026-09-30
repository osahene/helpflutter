import 'package:dio/dio.dart';
import 'package:helpflutter/core/constants/api_service.dart';
import 'package:helpflutter/data/models/tutorial.dart';

abstract class TutorialRepository {
  Future<List<Tutorial>> getTutorials();
}

/// Real implementation — fetches whatever's currently published in the
/// admin portal (see AppConstants.tutorials). Replaces MockTutorialRepository
/// below, which is kept only for tests/offline dev.
class TutorialRepositoryImpl implements TutorialRepository {
  final ApiService apiService;

  TutorialRepositoryImpl({required this.apiService});

  @override
  Future<List<Tutorial>> getTutorials() async {
    try {
      final response = await apiService.getTutorials();
      final data = response.data;
      final List list = data is List ? data : (data['results'] ?? []);
      return list.map((json) => Tutorial.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.response?.data?['detail']?.toString() ??
          e.message ??
          'Failed to load tutorials';
    }
  }
}

class MockTutorialRepository implements TutorialRepository {
  final List<Tutorial> _mockTutorials = [
    Tutorial(
      id: '1',
      title: 'How to use fire extinguisher',
      category: 'fire',
      videoUrl: 'https://www.youtube.com/watch?v=PQV71INDaqY',
    ),
    Tutorial(
      id: '2',
      title: 'First aid for burns',
      category: 'health',
      videoUrl: 'https://www.youtube.com/watch?v=iajIQ5C1XyA',
    ),
    Tutorial(
      id: '3',
      title: 'Flood safety tips',
      category: 'flood',
      videoUrl: 'https://www.youtube.com/watch?v=UvyDdWMZm40',
    ),
    Tutorial(
      id: '4',
      title: 'Robbery prevention',
      category: 'robbery',
      videoUrl: 'https://www.youtube.com/watch?v=LQdHjDrZZNk',
    ),
    Tutorial(
      id: '5',
      title: 'Accident response',
      category: 'accident',
      videoUrl: 'https://www.youtube.com/watch?v=NUSfkoSwYBs',
    ),
  ];

  @override
  Future<List<Tutorial>> getTutorials() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockTutorials;
  }
}
