import 'package:flutter_test/flutter_test.dart';
import 'package:helpflutter/data/models/titbit.dart';

void main() {
  group('Titbit.fromJson', () {
    test('parses a fully populated, unread Titbit', () {
      final titbit = Titbit.fromJson({
        'id': 'n1',
        'category': 'weather',
        'title': 'Storm warning',
        'body': 'Heavy rain expected tonight.',
        'icon': '⛈️',
        'image': 'https://example.com/storm.jpg',
        'source': 'GMet',
        'related_emergency_id': 'e1',
        'created_at': '2026-08-01T10:00:00.000Z',
        'read_at': null,
      });

      expect(titbit.id, 'n1');
      expect(titbit.category, 'weather');
      expect(titbit.title, 'Storm warning');
      expect(titbit.body, 'Heavy rain expected tonight.');
      expect(titbit.icon, '⛈️');
      expect(titbit.image, 'https://example.com/storm.jpg');
      expect(titbit.source, 'GMet');
      expect(titbit.relatedEmergencyId, 'e1');
      expect(titbit.createdAt, DateTime.parse('2026-08-01T10:00:00.000Z'));
      expect(titbit.readAt, isNull);
      expect(titbit.isUnread, isTrue);
    });

    test('applies defaults for missing optional string fields', () {
      final titbit = Titbit.fromJson({
        'id': 'n2',
        'created_at': '2026-08-01T10:00:00.000Z',
      });

      expect(titbit.category, 'general');
      expect(titbit.title, '');
      expect(titbit.body, '');
      expect(titbit.icon, isNull);
    });

    test('a non-null read_at makes isUnread false', () {
      final titbit = Titbit.fromJson({
        'id': 'n3',
        'created_at': '2026-08-01T10:00:00.000Z',
        'read_at': '2026-08-02T10:00:00.000Z',
      });

      expect(titbit.isUnread, isFalse);
    });
  });

  group('Titbit.copyWith', () {
    test('marks a Titbit read without changing other fields', () {
      final original = Titbit.fromJson({
        'id': 'n1',
        'title': 'Storm warning',
        'created_at': '2026-08-01T10:00:00.000Z',
      });
      final readAt = DateTime.parse('2026-08-02T10:00:00.000Z');

      final updated = original.copyWith(readAt: readAt);

      expect(updated.readAt, readAt);
      expect(updated.isUnread, isFalse);
      expect(updated.id, original.id);
      expect(updated.title, original.title);
    });
  });

  group('TitbitPage.fromJson', () {
    test('parses a paginated page of results', () {
      final page = TitbitPage.fromJson({
        'count': 2,
        'next': 'https://api.example.com/notifications/?page=2',
        'previous': null,
        'results': [
          {'id': 'n1', 'created_at': '2026-08-01T10:00:00.000Z'},
          {'id': 'n2', 'created_at': '2026-08-02T10:00:00.000Z'},
        ],
      });

      expect(page.count, 2);
      expect(page.next, 'https://api.example.com/notifications/?page=2');
      expect(page.previous, isNull);
      expect(page.results, hasLength(2));
      expect(page.results.first.id, 'n1');
    });

    test('defaults to an empty page when fields are missing', () {
      final page = TitbitPage.fromJson({});

      expect(page.count, 0);
      expect(page.next, isNull);
      expect(page.previous, isNull);
      expect(page.results, isEmpty);
    });
  });
}
