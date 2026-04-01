import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/core/theme/theme.dart';
import 'package:helpflutter/data/repositories/auth_repository.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';
import 'package:helpflutter/data/repositories/emergency_repository.dart';
import 'package:helpflutter/logic/auth/auth_bloc.dart';
import 'package:helpflutter/logic/contacts/contacts_bloc.dart';
import 'package:helpflutter/logic/emergency/emergency_bloc.dart';
import 'package:helpflutter/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:helpflutter/presentation/screens/auth/login_screen.dart';
import 'package:helpflutter/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:helpflutter/core/constants/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  final isLoggedIn = await SecureStorage.isLoggedIn();

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding, isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.hasSeenOnboarding,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(AuthRepository())),
        BlocProvider(create: (_) => ContactsBloc(ContactsRepository())),
        BlocProvider(create: (_) => EmergencyBloc(EmergencyRepository())),
      ],
      child: MaterialApp(
        title: 'Help Oo Help',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: _getInitialScreen(),
      ),
    );
  }

  Widget _getInitialScreen() {
    if (!hasSeenOnboarding) {
      return const OnboardingScreen();
    } else if (!isLoggedIn) {
      return const LoginScreen();
    } else {
      return const DashboardScreen();
    }
  }
}
