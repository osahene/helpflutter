import 'package:flutter/material.dart';
import 'package:helpflutter/data/repositories/emergency_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = EmergencyRepository();
    final nationalNumbers = repo.getNationalNumbers();
    final helpContacts = repo.getHelpOoHelpContacts();

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'National Emergency Numbers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...nationalNumbers.map((item) {
            return ListTile(
              leading: Text(item.icon, style: const TextStyle(fontSize: 24)),
              title: Text(item.name),
              subtitle: Text(item.phone),
              trailing: const Icon(Icons.phone),
              onTap: () => _makePhoneCall(item.phone),
            );
          }),
          const Divider(height: 32),
          const Text(
            'Help Oo Help Organization',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: const Text('Call'),
            subtitle: Text(helpContacts['phone']!),
            onTap: () => _makePhoneCall(helpContacts['phone']!),
          ),
          ListTile(
            leading: const Icon(Icons.message, color: Colors.green),
            title: const Text('WhatsApp'),
            subtitle: Text(helpContacts['whatsapp']!),
            onTap: () => _launchUrl(helpContacts['whatsapp']!),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.green),
            title: const Text('Email'),
            subtitle: Text(helpContacts['email']!),
            onTap: () => _launchUrl('mailto:${helpContacts['email']}'),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.green),
            title: const Text('Website'),
            subtitle: Text(helpContacts['website']!),
            onTap: () => _launchUrl(helpContacts['website']!),
          ),
          // Add socials if needed
        ],
      ),
    );
  }
}
