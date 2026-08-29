import 'package:flutter_test/flutter_test.dart';
import 'package:helpflutter/data/models/incoming_alert.dart';

void main() {
  group('IncomingAlert.fromJson', () {
    test('parses all fields, including a present location', () {
      final alert = IncomingAlert.fromJson({
        'emergency_id': 'e1',
        'reporter': {'name': 'Ama Serwaa', 'phone': '+233241234567'},
        'situation': 'fire',
        'situation_display': 'Fire outbreak',
        'location': {'latitude': 5.614, 'longitude': -0.208},
        'location_display': 'Osu, Accra, Greater Accra',
        'alert_code': 'AB12CD34',
        'is_verified': false,
        'created_at': '2026-08-29T10:00:00Z',
      });

      expect(alert.emergencyId, 'e1');
      expect(alert.reporter.name, 'Ama Serwaa');
      expect(alert.reporter.phone, '+233241234567');
      expect(alert.situation, 'fire');
      expect(alert.situationDisplay, 'Fire outbreak');
      expect(alert.location, isNotNull);
      expect(alert.location!.latitude, 5.614);
      expect(alert.location!.longitude, -0.208);
      expect(alert.locationDisplay, 'Osu, Accra, Greater Accra');
      expect(alert.alertCode, 'AB12CD34');
      expect(alert.isVerified, false);
      expect(alert.createdAt, DateTime.parse('2026-08-29T10:00:00Z'));
    });

    test('leaves location null when the reporter never got a GPS fix', () {
      final alert = IncomingAlert.fromJson({
        'emergency_id': 'e2',
        'reporter': {'name': 'Kwame', 'phone': '+233551234567'},
        'situation': 'health',
        'situation_display': 'Health Crisis',
        'location': null,
        'location_display': '5.614, -0.208',
        'alert_code': 'ZZ99YY88',
        'is_verified': true,
        'created_at': '2026-08-29T10:00:00Z',
      });

      expect(alert.location, isNull);
      expect(alert.locationDisplay, '5.614, -0.208');
      expect(alert.isVerified, true);
    });

    test('falls back sensibly when optional fields are missing', () {
      final alert = IncomingAlert.fromJson({
        'emergency_id': 'e3',
        'alert_code': 'CODE1234',
      });

      expect(alert.reporter.name, '');
      expect(alert.reporter.phone, '');
      expect(alert.situation, 'other');
      expect(alert.situationDisplay, 'Emergency');
      expect(alert.location, isNull);
      expect(alert.locationDisplay, 'Location unavailable');
      expect(alert.isVerified, false);
    });
  });
}
