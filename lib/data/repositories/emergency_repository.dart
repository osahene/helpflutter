import 'package:helpflutter/core/constants/app_constants.dart';
import 'package:helpflutter/data/models/emergency_number.dart';

class EmergencyRepository {
  List<EmergencyNumber> getNationalNumbers() {
    return AppConstants.nationalEmergencies
        .map(
          (e) => EmergencyNumber(
            name: e['name']!,
            phone: e['phone']!,
            icon: e['icon']!,
          ),
        )
        .toList();
  }

  List<Map<String, dynamic>> getHelpOoHelpContacts() {
    return AppConstants.helpOoHelpContacts;
  }
}
