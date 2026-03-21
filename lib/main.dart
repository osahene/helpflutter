import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:helpflutter/core/theme/theme.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';
import 'package:helpflutter/data/repositories/dependent_repository.dart';
import 'package:helpflutter/data/repositories/live_report_repository.dart';
import 'package:helpflutter/data/repositories/tutorial_repository.dart';
import 'package:helpflutter/data/repositories/profile_repository.dart';
import 'package:helpflutter/data/repositories/alert_repository.dart';
import 'package:helpflutter/data/repositories/auth_repository.dart'; // ✅ Add this
import 'package:helpflutter/logic/blocs/auth/auth_bloc.dart'; // ✅ Add this
import 'package:helpflutter/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:helpflutter/presentation/screens/login/login_screen.dart'; // ✅ Adjust path if needed
import 'package:helpflutter/presentation/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    // Simulate loading (e.g., load user data)
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories (using Provider)
        Provider<ContactRepository>(create: (_) => MockContactRepository()),
        Provider<DependentRepository>(create: (_) => MockDependentRepository()),
        Provider<LiveReportRepository>(
          create: (_) => MockLiveReportRepository(),
        ),
        Provider<TutorialRepository>(create: (_) => MockTutorialRepository()),
        Provider<ProfileRepository>(create: (_) => MockProfileRepository()),
        Provider<AlertRepository>(
          create: (_) => AlertRepositoryImpl(
            baseUrl: 'https://your-production-backend.com/api',
          ),
        ),
        // ✅ Add AuthRepository
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(
            baseUrl: 'https://your-production-backend.com/api',
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // ✅ Add AuthBloc (requires AuthRepository)
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(repository: context.read<AuthRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Help Oo Help',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          // ✅ Replace initialRoute with a splash screen that decides
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

// ✅ New SplashScreen widget that checks onboarding and auth state
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentIndex = 0;
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Trigger auth status check after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(CheckAuthStatus());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            // User is logged in → go to home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(
                  currentIndex: _currentIndex,
                  onTabTapped: _onTabTapped,
                ),
              ),
            );
          } else if (state is Unauthenticated) {
            // Not logged in → check if onboarding was completed
            _checkOnboardingAndNavigate();
          } else if (state is AuthError) {
            // On error, also check onboarding
            _checkOnboardingAndNavigate();
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 120),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkOnboardingAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    if (!mounted) return;

    if (onboardingCompleted) {
      // Onboarding seen → go to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      // First time → show onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }
}
