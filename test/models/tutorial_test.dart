import 'package:flutter_test/flutter_test.dart';
import 'package:helpflutter/data/models/tutorial.dart';

void main() {
  group('Tutorial.fromJson', () {
    test('parses required fields and duration', () {
      final tutorial = Tutorial.fromJson({
        'id': 't1',
        'title': 'Basic First Aid',
        'category': 'health',
        'video_url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        'duration_seconds': 125,
      });

      expect(tutorial.id, 't1');
      expect(tutorial.title, 'Basic First Aid');
      expect(tutorial.category, 'health');
      expect(tutorial.duration, const Duration(seconds: 125));
    });

    test('duration is null when duration_seconds is absent', () {
      final tutorial = Tutorial.fromJson({
        'id': 't2',
        'title': 'Fire Safety',
        'category': 'safety',
        'video_url': 'https://youtu.be/dQw4w9WgXcQ',
      });

      expect(tutorial.duration, isNull);
    });
  });

  group('Tutorial.youtubeVideoId', () {
    test('parses a standard youtube.com/watch?v= URL', () {
      final tutorial = Tutorial(
        id: '1',
        title: 't',
        category: 'c',
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );

      expect(tutorial.youtubeVideoId, 'dQw4w9WgXcQ');
    });

    test('parses a shortened youtu.be/ URL', () {
      final tutorial = Tutorial(
        id: '1',
        title: 't',
        category: 'c',
        videoUrl: 'https://youtu.be/dQw4w9WgXcQ',
      );

      expect(tutorial.youtubeVideoId, 'dQw4w9WgXcQ');
    });

    test('returns null for a URL with no video id', () {
      final tutorial = Tutorial(
        id: '1',
        title: 't',
        category: 'c',
        videoUrl: 'https://example.com/not-youtube',
      );

      expect(tutorial.youtubeVideoId, isNull);
    });

    test('returns null for an unparseable URL', () {
      final tutorial = Tutorial(
        id: '1',
        title: 't',
        category: 'c',
        videoUrl: '::not a uri::',
      );

      expect(tutorial.youtubeVideoId, isNull);
    });
  });

  group('Tutorial.thumbnailUrl', () {
    test('builds the hqdefault thumbnail URL from a valid video id', () {
      final tutorial = Tutorial(
        id: '1',
        title: 't',
        category: 'c',
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      );

      expect(
        tutorial.thumbnailUrl,
        'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
      );
    });

    test('is null when the video id cannot be parsed', () {
      final tutorial = Tutorial(
        id: '1',
        title: 't',
        category: 'c',
        videoUrl: 'https://example.com/not-youtube',
      );

      expect(tutorial.thumbnailUrl, isNull);
    });
  });
}
