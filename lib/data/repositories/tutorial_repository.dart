import 'package:helpflutter/data/models/tutorial.dart';

abstract class TutorialRepository {
  Future<List<Tutorial>> getTutorials();
}

class MockTutorialRepository implements TutorialRepository {
  final List<Tutorial> _mockTutorials = [
    Tutorial(
      id: '1',
      title: 'How to use fire extinguisher',
      category: 'fire',
      thumbnailUrl: 'https://via.placeholder.com/150',
      videoUrl: 'https://www.youtube.com/watch?v=PQV71INDaqY',
    ),
    Tutorial(
      id: '2',
      title: 'First aid for burns',
      category: 'health',
      thumbnailUrl: 'https://via.placeholder.com/150',
      videoUrl: 'https://www.youtube.com/watch?v=iajIQ5C1XyA',
    ),
    Tutorial(
      id: '3',
      title: 'Flood safety tips',
      category: 'flood',
      thumbnailUrl: 'https://via.placeholder.com/150',
      videoUrl: 'https://www.youtube.com/watch?v=UvyDdWMZm40',
    ),
    Tutorial(
      id: '4',
      title: 'Robbery prevention',
      category: 'robbery',
      thumbnailUrl: 'https://via.placeholder.com/150',
      videoUrl: 'https://www.youtube.com/watch?v=LQdHjDrZZNk',
    ),
    Tutorial(
      id: '5',
      title: 'Accident response',
      category: 'accident',
      thumbnailUrl: 'https://via.placeholder.com/150',
      videoUrl: 'https://www.youtube.com/watch?v=NUSfkoSwYBs',
    ),
  ];

  @override
  Future<List<Tutorial>> getTutorials() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockTutorials;
  }
}
