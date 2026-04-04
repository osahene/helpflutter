import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Help Oo Help';
  static const String baseUrl =
      'https://your-backend-url.com/api'; // Change to your backend
  static const String apiKey = 'your-api-key'; // If needed
  static const String logoPath = 'assets/logo/logo.png';

  // Endpoints
  static const String register = '/user-register/';
  static const String login = '/user-login/';
  static const String sendOtp = '/send-otp/';
  static const String verifyOtp = '/verify-otp/';
  static const String inviteStatus = '/invite-status/';
  static const String createContact = '/create-relation/';
  static const String myContacts = '/my-contacts/';
  static const String myDependents = '/my-dependents/';
  static const String approveDependant = '/approve-dependant/';
  static const String rejectDependant = '/reject-dependant/';
  static const String deleteContact = '/delete-contact/';
  static const String updateContact = '/update-contact/';
  static const String verifyEmergency = '/verify-emergency/';
  static const String decodeEmergencyToken = '/decode-emergency-token/';

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
      'icon': Icons.message, // we'll use Material Icons for simplicity
      'actions': ['+233506053020'],
      'link': 'https://wa.me/233506053020',
    },
    {
      'id': 2,
      'name': 'Facebook',
      'icon': Icons.facebook,
      'actions': 'Visit Facebook',
      'link': 'https://facebook.com/home',
    },
    {
      'id': 3,
      'name': 'Twitter',
      'icon': Icons.help_center, // using generic; you can use custom icons
      'actions': 'Visit Twitter',
      'link': 'https://twitter.com/home',
    },
    {
      'id': 4,
      'name': 'Call',
      'icon': Icons.phone,
      'actions': ['+233546045726'],
    },
  ];
}
