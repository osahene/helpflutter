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

    test('message reads like the SMS the contact received', () {
      final alert = IncomingAlert.fromJson({
        'emergency_id': 'e4',
        'reporter': {'name': 'Eric Mensah', 'phone': '+233244000000'},
        'situation': 'health',
        'situation_display': 'Health crisis',
        'location_display': 'Osu, Accra',
        'alert_code': 'CODE',
        'contact': {'first_name': 'Ama', 'last_name': 'Owusu', 'relation': 'Friend'},
        'maps_link': 'https://www.google.com/maps/search/?api=1&query=5.55,-0.18',
        'verification_link': 'https://helpoohelp.com/verifyEmerg/verify?code=CODE',
      });

      expect(alert.message, startsWith('Health crisis Alert,\n\nHello Ama Owusu,'));
      expect(
        alert.message,
        contains('Your friend, Eric Mensah, has triggered an emergency '
            'health crisis alert. They are at Osu, Accra.'),
      );
      expect(alert.mapsLink, contains('query=5.55,-0.18'));
      expect(alert.verificationLink, endsWith('code=CODE'));
    });

    test('message still reads well without contact details', () {
      final alert = IncomingAlert.fromJson({
        'emergency_id': 'e5',
        'reporter': {'name': 'Eric Mensah'},
        'situation_display': 'Fire outbreak',
        'location_display': 'Kumasi',
      });

      expect(alert.message, startsWith('Fire outbreak Alert,\n\nHello,'));
      expect(alert.message, contains('Eric Mensah has triggered'));
    });
  });
}
