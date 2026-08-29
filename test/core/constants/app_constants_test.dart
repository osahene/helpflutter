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
}
