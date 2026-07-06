import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/logic/auth/auth_bloc.dart';
import 'package:helpflutter/presentation/screens/dashboard/home_screen.dart';
import 'package:helpflutter/presentation/screens/dashboard/contact_screen.dart';
import 'package:helpflutter/presentation/screens/dashboard/register_contact_screen.dart';
import 'package:helpflutter/presentation/screens/dashboard/emergency_contacts_screen.dart';
import 'package:helpflutter/presentation/screens/extra/video_tutorials_screen.dart';
import 'package:helpflutter/presentation/widgets/bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final List<int> _history = [0];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> get _screens => [
    HomeScreen(
      onTabTapped: (int index) {},
      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
    ),
    const RegisterContactScreen(),
    const ContactsScreen(),
    const EmergencyContactsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          _history.length <=
          1, // Only allow "Exit" if we are already on the Home tab
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return; // If the app actually popped, do nothing

        // If we are on Contacts, Register, or Emergency, go back to Home instead of exiting
        if (_history.length > 1) {
          setState(() {
            _history.removeLast(); // Remove the current page from history
            _currentIndex =
                _history.last; // Go to the page we visited previously
          });
        } else {
          // If we are on Home and the user tries to pop, allow the app to exit
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildAppDrawer(context),
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (_currentIndex != index) {
              setState(() {
                _currentIndex = index;
                _history.remove(
                  index,
                ); // Remove the page if it's already in history to avoid duplicates
                _history.add(index); // Add the new page to our history stack
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Custom Header to match your TopNavBar gradient
          DrawerHeader(
            padding: EdgeInsets.zero,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0A0A), Color(0xFF6B0F0F)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Help Oo Help',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // Tutorial Menu Item (Stays exactly where it is)
          ListTile(
            leading: const Icon(Icons.school_rounded, color: Colors.blue),
            title: const Text(
              'Tutorial',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoTutorialsScreen(),
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tutorial screen coming soon!')),
              );
            },
          ),
          const Spacer(),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

          // Logout Section pinned tightly to the bottom (wrapped in a SafeArea for modern device notches)
          SafeArea(
            top: false,
            child: ListTile(
              leading: Icon(Icons.logout_outlined, color: Colors.red.shade600),
              title: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.red.shade700,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close the drawer safely
                context.read<AuthBloc>().add(
                  AuthLogoutRequested(),
                ); // Trigger state change

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully!')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
