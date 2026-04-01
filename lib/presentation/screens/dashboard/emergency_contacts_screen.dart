import 'package:flutter/material.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  Future<void> _call(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: AppConstants.nationalEmergencies.length,
        itemBuilder: (context, index) {
          final item = AppConstants.nationalEmergencies[index];
          return Card(
            child: ListTile(
              leading: Text(
                item['icon']!,
                style: const TextStyle(fontSize: 30),
              ),
              title: Text(item['name']!),
              subtitle: Text(item['phone']!),
              trailing: IconButton(
                icon: const Icon(Icons.phone, color: Colors.green),
                onPressed: () => _call(item['phone']!),
              ),
              onTap: () => _call(item['phone']!),
            ),
          );
        },
      ),
    );
  }
}
