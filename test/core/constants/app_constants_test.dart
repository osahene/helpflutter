import 'package:flutter_test/flutter_test.dart';
import 'package:helpflutter/core/constants/constants.dart';

void main() {
  group('AppConstants.situationToAlertType', () {
    test('maps every display situation to a backend alert-type code', () {
      expect(AppConstants.situationToAlertType['Fire Outbreak'], 'fire');
      expect(AppConstants.situationToAlertType['Health Crisis'], 'health');
      expect(AppConstants.situationToAlertType['Robbery Attack'], 'robbery');
      expect(AppConstants.situationToAlertType['Violence Alert'], 'violence');
      expect(AppConstants.situationToAlertType['Flood Alert'], 'flood');
      expect(AppConstants.situationToAlertType['Call Emergency'], 'other');
    });

    test('has exactly one mapping per entry in situations, and vice versa', () {
      // Guards against the two lists silently drifting apart — every
      // display string in `situations` must have a mapping, and the map
      // must not contain stale/extra keys not present in `situations`.
      expect(
        AppConstants.situationToAlertType.keys.toSet(),
        AppConstants.situations.toSet(),
      );
    });

    test('returns null for an unmapped situation', () {
      expect(AppConstants.situationToAlertType['Not A Real Situation'], isNull);
    });
  });

  group('AppConstants.emergencyServiceFor', () {
    String serviceName(String situation) =>
        AppConstants.emergencyServiceFor(situation)['name'] as String;

    test('routes each situation to the right national service', () {
      expect(serviceName('Robbery Attack'), 'Ghana Police');
      expect(serviceName('Call Emergency'), 'Ghana Police');
      expect(serviceName('Violence Alert'), 'Ghana Police');
      expect(serviceName('Fire Outbreak'), 'Ghana National Fire Service');
      expect(serviceName('Health Crisis'), 'National Ambulance Service');
      expect(serviceName('Accident Alert'), 'National Ambulance Service');
      expect(
        serviceName('Flood Alert'),
        'National Disaster Management Organization',
      );
    });

    test('falls back to the police for an unknown situation', () {
      expect(serviceName('Not A Real Situation'), 'Ghana Police');
    });

    test('every mapped service exists in nationalEmergencies', () {
      final names = AppConstants.nationalEmergencies.map((s) => s['name']);
      for (final service in AppConstants.situationEmergencyService.values) {
        expect(names, contains(service));
      }
    });
  });
}
