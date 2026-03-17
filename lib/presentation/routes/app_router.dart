import 'package:flutter/material.dart';
import 'package:helpflutter/presentation/screens/contact/contact_screen.dart';
import 'package:helpflutter/presentation/screens/emergency_contact/emergency_contacts_screen.dart';
import 'package:helpflutter/presentation/screens/home/home_screen.dart';
import 'package:helpflutter/presentation/screens/live_report/live_report_screen.dart';
import 'package:helpflutter/presentation/screens/register/register_contact_screen.dart';
import 'package:helpflutter/presentation/screens/video_tutorials/video_tutorials_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String register = '/register';
  static const String contacts = '/contacts';
  static const String emergency = '/emergency';
  static const String liveReport = '/live-report';
  static const String tutorials = '/tutorials';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeWrapper());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterContactScreen());
      case contacts:
        return MaterialPageRoute(builder: (_) => const ContactsScreen());
      case emergency:
        return MaterialPageRoute(
          builder: (_) => const EmergencyContactsScreen(),
        );
      case liveReport:
        return MaterialPageRoute(builder: (_) => const LiveReportScreen());
      case tutorials:
        return MaterialPageRoute(builder: (_) => const VideoTutorialsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

// Wrapper to handle bottom navigation
class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(
      currentIndex: 0,
      onTabTapped: (index) {},
    ), // We'll pass a function that updates index from outside
    const RegisterContactScreen(),
    const ContactsScreen(),
    const EmergencyContactsScreen(),
    const LiveReportScreen(),
    const VideoTutorialsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild HomeScreen with updated onTabTapped
    final homeScreen = HomeScreen(
      currentIndex: _currentIndex,
      onTabTapped: _onTabTapped,
    );
    // Replace first screen with updated homeScreen
    _screens[0] = homeScreen;

    return Scaffold(
      body: _screens[_currentIndex],
      // Use BottomNavigationBar if you don't have a custom BottomNavBar widget
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        // The built-in widget requires 'items' to be defined
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Register',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Tutorials',
          ),
        ],
      ),
    );
  }
}
