import 'package:flutter_test/flutter_test.dart';
import 'package:helpflutter/data/models/alert.dart';

void main() {
  group('Alert.fromJson / toJson round trip', () {
    test('round-trips a fully populated alert', () {
      final json = {
        'id': 'al1',
        'situation': 'Fire Outbreak',
        'timestamp': '2026-08-01T10:00:00.000Z',
        'includeLocation': true,
        'customMessage': 'Kitchen fire, send help',
        'notifiedContactIds': ['c1', 'c2'],
      };

      final alert = Alert.fromJson(json);

      expect(alert.id, 'al1');
      expect(alert.situation, 'Fire Outbreak');
      expect(alert.timestamp, DateTime.parse('2026-08-01T10:00:00.000Z'));
      expect(alert.includeLocation, isTrue);
      expect(alert.customMessage, 'Kitchen fire, send help');
      expect(alert.notifiedContactIds, ['c1', 'c2']);

      final roundTripped = Alert.fromJson(alert.toJson());
      expect(roundTripped.id, alert.id);
      expect(roundTripped.situation, alert.situation);
      expect(roundTripped.timestamp, alert.timestamp);
      expect(roundTripped.includeLocation, alert.includeLocation);
      expect(roundTripped.customMessage, alert.customMessage);
      expect(roundTripped.notifiedContactIds, alert.notifiedContactIds);
    });

    test('accepts the backend snake_case field aliases', () {
      final alert = Alert.fromJson({
        'id': 'al2',
        'alertType': 'Flood Alert',
        'timestamp': '2026-08-01T10:00:00.000Z',
        'include_location': false,
        'message': 'Water rising fast',
      });

      expect(alert.situation, 'Flood Alert');
      expect(alert.includeLocation, isFalse);
      expect(alert.customMessage, 'Water rising fast');
      expect(alert.notifiedContactIds, isEmpty);
    });

    test('falls back sensibly when fields are entirely missing', () {
      final alert = Alert.fromJson(const {});

      expect(alert.id, '');
      expect(alert.situation, 'Emergency');
      expect(alert.includeLocation, isFalse);
      expect(alert.customMessage, isNull);
      expect(alert.notifiedContactIds, isEmpty);
    });
  });
}
