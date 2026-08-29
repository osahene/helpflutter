import 'package:flutter_test/flutter_test.dart';
import 'package:helpflutter/data/models/agency.dart';

void main() {
  group('Agency.fromJson', () {
    test('parses all fields', () {
      final agency = Agency.fromJson({
        'id': 'a1',
        'name': 'Ghana Police Service',
        'service': 'police',
        'phone': '191',
      });

      expect(agency.id, 'a1');
      expect(agency.name, 'Ghana Police Service');
      expect(agency.service, 'police');
      expect(agency.phone, '191');
    });

    test('falls back to an empty string when phone is missing', () {
      final agency = Agency.fromJson({
        'id': 'a2',
        'name': 'Some Agency',
        'service': 'fire',
      });

      expect(agency.phone, '');
    });
  });

  group('Agency.icon', () {
    test('maps known service types to their emoji', () {
      Agency agencyFor(String service) => Agency(
        id: '1',
        name: 'n',
        service: service,
        phone: '',
      );

      expect(agencyFor('police').icon, '👮');
      expect(agencyFor('fire').icon, '🔥');
      expect(agencyFor('ambulance').icon, '🚑');
      expect(agencyFor('ecg').icon, '⚡');
    });

    test('falls back to a generic building icon for unknown services', () {
      final agency = Agency(id: '1', name: 'n', service: 'unknown', phone: '');
      expect(agency.icon, '🏢');
    });
  });
}
