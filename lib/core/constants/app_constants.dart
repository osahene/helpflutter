import 'package:flutter/material.dart';

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
      'name': 'Ambulance Service',
      'phone': ['+2330501614877', '+2330505982870'],
      'icon': '🚑',
    },
    {
      'name': 'Electricity Company of Ghana',
      'phone': ['+233302676727', '+233302611611', '+233302676728'],
      'icon': '⚡',
    },
    {
      'name': 'NADMO',
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
