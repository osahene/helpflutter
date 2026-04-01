import 'package:flutter/material.dart';
import 'package:helpflutter/presentation/screens/dashboard/home_screen.dart';
import 'package:helpflutter/presentation/screens/dashboard/contact_screen.dart';
import 'package:helpflutter/presentation/screens/dashboard/register_contact_screen.dart';
import 'package:helpflutter/presentation/screens/dashboard/emergency_contacts_screen.dart';
import 'package:helpflutter/presentation/widgets/bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const ContactsScreen(),
    const RegisterContactScreen(),
    const EmergencyContactsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
