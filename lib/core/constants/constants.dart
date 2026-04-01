class AppConstants {
  static const String appName = 'Help Oo Help';
  static const String baseUrl =
      'https://your-backend-url.com/api'; // Change to your backend
  static const String apiKey = 'your-api-key'; // If needed

  // Endpoints
  static const String register = '/user-register/';
  static const String sendOtp = '/send-otp/';
  static const String verifyOtp = '/verify-otp/';
  static const String createContact = '/create-relation/';
  static const String myContacts = '/my-contacts/';
  static const String deleteContact = '/delete-contact/';
  static const String triggerAlert = '/trigger-alert/';
  static const String refreshToken = '/token/refresh/';
  static const String logout = '/user-logout/';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String isLoggedInKey = 'is_logged_in';
  static const String hasSeenOnboarding = 'has_seen_onboarding';

  // Emergency situations (matches backend)
  static const List<String> situations = [
    'Fire Outbreak',
    'Health Crisis',
    'Robbery Attack',
    'Violence Alert',
    'Flood Alert',
    'Call Emergency',
  ];

  // National emergency numbers (local)
  static const List<Map<String, String>> nationalEmergencies = [
    {'name': 'Ghana Police', 'phone': '191', 'icon': '👮'},
    {'name': 'Ghana National Fire Service', 'phone': '192', 'icon': '🔥'},
    {'name': 'Ambulance Service', 'phone': '193', 'icon': '🚑'},
    {'name': 'NADMO', 'phone': '0302979507', 'icon': '🌊'},
  ];
}
