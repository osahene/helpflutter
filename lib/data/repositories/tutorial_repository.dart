import 'package:helpflutter/data/models/tutorial.dart';

abstract class TutorialRepository {
  Future<List<Tutorial>> getTutorials();
}

class MockTutorialRepository implements TutorialRepository {
  final List<Tutorial> _mockTutorials = [
    Tutorial(
      id: '1',
      title: 'How to handle a fire',
      category: 'fire',
      thumbnailUrl: 'https://via.placeholder.com/150',
      videoUrl: 'https://www.youtube.com/watch?v=example1',
    ),
    Tutorial(
      id: '2',
      title: 'First aid for burns',
      category: 'health',
      thumbnailUrl: 'https://via.placeholder.com/150',
      videoUrl: 'https://www.youtube.com/watch?v=example2',
    ),
    Tutorial(
      id: '3',
      title: 'Flood safety tips',
      category: 'flood',
      thumbnailUrl: 'https://via.placeholder.com/150',
      videoUrl: 'https://www.youtube.com/watch?v=example3',
    ),
    Tutorial(
      id: '4',
      title: 'Robbery prevention',
      category: 'robbery',
      thumbnailUrl: 'https://via.placeholder.com/150',
      videoUrl: 'https://www.youtube.com/watch?v=example4',
    ),
    Tutorial(
      id: '5',
      title: 'Accident response',
      category: 'accident',
      thumbnailUrl: 'https://via.placeholder.com/150',
      videoUrl: 'https://www.youtube.com/watch?v=example5',
    ),
  ];

  @override
  Future<List<Tutorial>> getTutorials() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockTutorials;
  }
}
