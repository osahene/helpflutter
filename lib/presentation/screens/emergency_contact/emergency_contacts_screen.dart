import 'package:flutter/material.dart';
import 'package:helpflutter/core/constants/app_constants.dart';
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
    final nationalNumbers = AppConstants.nationalEmergencies;
    final helpContacts = AppConstants.helpOoHelpContacts;

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
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            Text(
              '🚨 National Emergencies',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...nationalNumbers.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item['name']!.contains('Police')
                            ? Colors.blue.shade50
                            : Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        item['icon']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    title: Text(
                      item['name']!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(item['phone']!),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.phone, color: Colors.green.shade700),
                        onPressed: () => _makePhoneCall(item['phone']!),
                      ),
                    ),
                    onTap: () => _makePhoneCall(item['phone']!),
                  ),
                ),
              );
            }).toList(),
            const Divider(height: 32, thickness: 1),
            Text(
              '🤝 Help Oo Help Organization',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Use a grid or list for organization contacts
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildOrgCard(
                  context,
                  Icons.phone,
                  'Call',
                  helpContacts['phone']!,
                  Colors.green,
                  () => _makePhoneCall(helpContacts['phone']!),
                ),
                _buildOrgCard(
                  context,
                  Icons.message,
                  'WhatsApp',
                  helpContacts['whatsapp']!,
                  Colors.teal,
                  () => _launchUrl(helpContacts['whatsapp']!),
                ),
                _buildOrgCard(
                  context,
                  Icons.email,
                  'Email',
                  helpContacts['email']!,
                  Colors.blue,
                  () => _launchUrl('mailto:${helpContacts['email']}'),
                ),
                _buildOrgCard(
                  context,
                  Icons.language,
                  'Website',
                  helpContacts['website']!,
                  Colors.purple,
                  () => _launchUrl(helpContacts['website']!),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgCard(
    BuildContext context,
    IconData icon,
    String label,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width:
            (MediaQuery.of(context).size.width - 56) /
            2, // two columns with spacing
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
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
