import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppConstants {
  static const String appName = 'Help Oo Help';
  static const String logoPath = 'assets/logo/logo.png';

  // Endpoints
  static const String register = '/account/user-register/';
  static const String login = '/account/user-login/';
  static const String sendOtp = '/account/send-otp/';
  static const String verifyOtp = '/account/verify-otp/';
  static const String getHistory = '/account/user-history/';
  static const String inviteStatus = '/account/invite-status/';
  static const String createContact = '/account/create-relation/';
  static const String myContacts = '/account/my-contacts/';
  static const String myDependents = '/account/my-dependants/';
  static const String approveDependant = '/account/approve-dependent/';
  static const String rejectDependant = '/account/reject-dependent/';
  static const String deleteContact = '/account/delete-contact/';
  static const String updateContact = '/account/update-contact/';
  static const String verifyEmergency = '/account/verify-emergency/';
  static const String decodeEmergencyToken = '/account/decode-emergency-token/';

  static const String triggerAlert = '/account/trigger-alert/';
  static const String refreshToken = '/account/token/refresh/';
  static const String logout = '/account/user-logout/';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String isLoggedInKey = 'is_logged_in';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String cookieStorageDir = 'help_oo_help_cookies';

  // Emergency situations (matches backend)
  static const List<String> situations = [
    'Fire Outbreak',
    'Health Crisis',
    'Robbery Attack',
    'Violence Alert',
    'Flood Alert',
    'Call Emergency',
  ];

  static const List<String> situationIcons = [
    'assets/icons/fire.png',
    'assets/icons/health.png',
    'assets/icons/robbery.png',
    'assets/icons/violence.png',
    'assets/icons/flood.png',
    'assets/icons/call.png',
  ];

  static const List<String> relations = [
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Son',
    'Daughter',
    'Husband',
    'Wife',
    'Friend',
    'Relative',
    'Neighbor',
  ];

  // National emergency numbers (local)
  static const List<Map<String, dynamic>> nationalEmergencies = [
    {
      'name': 'Ghana Police',
      'phone': ['191', '18555', '+233302773906'],
      'icon': '👮',
    },
    {
      'name': 'Ghana National Fire Service',
      'phone': ['192', '+233302772446', '+233299340383'],
      'icon': '🔥',
    },
    {
      'name': 'National Ambulance Service',
      'phone': ['+2330501614877', '+2330505982870'],
      'icon': '🚑',
    },
    {
      'name': 'Electricity Company of Ghana',
      'phone': ['+233302676727', '+233302611611', '+233302676728'],
      'icon': '🚑',
    },
    {
      'name': 'National Disaster Management Organization',
      'phone': ['112', '+233299350030', '+233302964884'],
      'icon': '🌊',
    },
  ];

  // Help Oo Help organization contacts
  static const List<Map<String, dynamic>> helpOoHelpContacts = [
    {
      'id': 1,
      'name': 'WhatsApp',
      'icon': FontAwesomeIcons.whatsapp, // ✅ Real WhatsApp icon
      'actions': ['+233506053020'],
      'link': 'https://wa.me/233506053020',
    },
    {
      'id': 2,
      'name': 'Facebook',
      'icon':
          FontAwesomeIcons.facebook, // ✅ Real Facebook icon (optional upgrade)
      'actions': 'Visit Facebook',
      'link': 'https://facebook.com/home',
    },
    {
      'id': 3,
      'name': 'Twitter',
      'icon': FontAwesomeIcons.xTwitter, // ✅ Real X (Twitter) icon
      'actions': 'Visit Twitter',
      'link': 'https://twitter.com/home',
    },
    {
      'id': 4,
      'name': 'Snapchat',
      'icon': FontAwesomeIcons.snapchat, // ✅ Real Snapchat icon
      'actions': 'Visit Snapchat',
      'link': 'https://snapchat.com/home',
    },
    {
      'id': 5,
      'name': 'TikTok',
      'icon': FontAwesomeIcons.tiktok, // ✅ Real TikTok icon
      'actions': 'Visit TikTok',
      'link': 'https://tiktok.com/home',
    },
    {
      'id': 6,
      'name': 'Call',
      'icon': FontAwesomeIcons.phone, // optional upgrade too
      'actions': ['+233546045726'],
    },
  ];
}
