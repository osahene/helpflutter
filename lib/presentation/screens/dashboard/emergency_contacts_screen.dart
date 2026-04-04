import 'package:flutter/material.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  Future<void> _call(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phone';
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
    final emergencyServices = AppConstants.nationalEmergencies;
    final contactUs = AppConstants.helpOoHelpContacts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade300, Colors.orange.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(context).padding.bottom + 16, // extra bottom padding
          ),
          children: [
            const SizedBox(height: 8),
            Text(
              '🚨 National Emergencies',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...emergencyServices.map((service) {
              final name = service['name'] as String;
              final contacts = service['phone'] as List<String>;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...contacts.map(
                          (phone) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.phone,
                                color: Colors.green.shade700,
                                size: 20,
                              ),
                            ),
                            title: Text(phone),
                            onTap: () => _call(phone),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const Divider(height: 32, thickness: 1),
            Text(
              '🤝 Help Oo Help Organization',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: contactUs.map((contact) {
                final name = contact['name'] as String;
                final icon = contact['icon'] as IconData;
                final actions = contact['actions'];
                final link = contact['link'] as String?;

                // Determine the action and display text
                VoidCallback? onTap;
                String displayText = '';

                if (name == 'WhatsApp' || name == 'Call') {
                  // actions is a list of phone numbers
                  if (actions is List && actions.isNotEmpty) {
                    final phone = actions.first.toString();
                    displayText = phone;
                    onTap = () => _call(phone);
                  }
                } else if (name == 'Facebook' || name == 'Twitter') {
                  // actions is a string description, link is the URL
                  displayText = actions.toString();
                  if (link != null && link.isNotEmpty) {
                    onTap = () => _launchUrl(link);
                  }
                } else {
                  // fallback
                  displayText = actions.toString();
                }

                return InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 56) / 2,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 32, color: Colors.teal),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
