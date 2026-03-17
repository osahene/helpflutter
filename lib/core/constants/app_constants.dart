class AppConstants {
  static const String appName = 'Help Oo Help';
  static const String logoPath = 'assets/logo.png'; // Add your logo asset

  // Emergency situations
  static const List<String> situations = [
    'Robbery',
    'Health',
    'Fire',
    'Flood',
    'Accident',
    'Violence',
  ];

  // Relations
  static const List<String> relations = [
    'Son',
    'Daughter',
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Friend',
    'Colleague',
    'Other',
  ];

  // National emergency contacts (Ghana)
  static const List<Map<String, String>> nationalEmergencies = [
    {'name': 'Ghana Police', 'phone': '191', 'icon': '👮'},
    {'name': 'Ghana National Fire Service', 'phone': '192', 'icon': '🔥'},
    {'name': 'Ambulance Service', 'phone': '193', 'icon': '🚑'},
    {
      'name': 'Electricity Company of Ghana',
      'phone': '0302611000',
      'icon': '⚡',
    },
    {'name': 'NADMO', 'phone': '0302979507', 'icon': '🌊'},
  ];

  // Help Oo Help organization contacts
  static const Map<String, String> helpOoHelpContacts = {
    'phone': '+233123456789',
    'whatsapp': 'https://wa.me/233123456789',
    'email': 'info@helpoohelp.com',
    'website': 'https://www.helpoohelp.com',
    'facebook': 'https://facebook.com/helpoohelp',
    'twitter': 'https://twitter.com/helpoohelp',
    'instagram': 'https://instagram.com/helpoohelp',
  };
}
