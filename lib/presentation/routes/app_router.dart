import 'package:flutter/material.dart';
import 'package:helpflutter/presentation/screens/contact/contact_screen.dart';
import 'package:helpflutter/presentation/screens/emergency_contact/emergency_contacts_screen.dart';
import 'package:helpflutter/presentation/screens/home/home_screen.dart';
import 'package:helpflutter/presentation/screens/live_report/live_report_screen.dart';
import 'package:helpflutter/presentation/screens/register_contacts/register_contact_screen.dart';
import 'package:helpflutter/presentation/screens/video_tutorials/video_tutorials_screen.dart';
import 'package:helpflutter/core/widgets/suspended_button_nav_bar.dart';
import 'package:helpflutter/presentation/screens/splashscreen/splash_screen.dart';

class AppRouter {
  static const String splash = '/'; // Added explicit splash route
  static const String home = '/home'; // Changed from '/' to '/home'
  static const String register = '/register';
  static const String contacts = '/contacts';
  static const String emergency = '/emergency';
  static const String liveReport = '/live-report';
  static const String tutorials = '/tutorials';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  // FIXED: Build screens dynamically rather than modifying a list inside build()
  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          currentIndex: _currentIndex,
          onTabTapped: _onTabTapped,
          onMenuTap: _openDrawer,
        );
      case 1:
        return const RegisterContactScreen();
      case 2:
        return const ContactsScreen();
      case 3:
        return const EmergencyContactsScreen();
      default:
        return HomeScreen(
          currentIndex: 0,
          onTabTapped: _onTabTapped,
          onMenuTap: _openDrawer,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      body: _buildCurrentScreen(), // Shows the screen based on index
      bottomNavigationBar: SuspendedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF6C5CE7)),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Live Report'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.liveReport);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Video Tutorials'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.tutorials);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
