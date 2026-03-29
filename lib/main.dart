import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:helpflutter/core/theme/theme.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';
import 'package:helpflutter/data/repositories/dependent_repository.dart';
import 'package:helpflutter/data/repositories/live_report_repository.dart';
import 'package:helpflutter/data/repositories/tutorial_repository.dart';
import 'package:helpflutter/data/repositories/profile_repository.dart';
import 'package:helpflutter/data/repositories/alert_repository.dart';
import 'package:helpflutter/data/repositories/auth_repository.dart';
import 'package:helpflutter/logic/blocs/auth/auth_bloc.dart';
import 'package:helpflutter/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:helpflutter/presentation/screens/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helpflutter/presentation/routes/app_router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
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
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ContactRepository>(create: (_) => MockContactRepository()),
        Provider<DependentRepository>(create: (_) => MockDependentRepository()),
        Provider<LiveReportRepository>(
          create: (_) => MockLiveReportRepository(),
        ),
        Provider<TutorialRepository>(create: (_) => MockTutorialRepository()),
        Provider<ProfileRepository>(create: (_) => MockProfileRepository()),
        Provider<AlertRepository>(
          create: (_) => AlertRepositoryImpl(baseUrl: dotenv.get('BASE_URL')),
        ),
        Provider<AuthRepository>(
          create: (_) => AuthRepositoryImpl(baseUrl: dotenv.get('BASE_URL')),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
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
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeWrapper()),
            );
          } else if (state is Unauthenticated) {
            _checkOnboardingAndNavigate();
          } else if (state is AuthError) {
            _checkOnboardingAndNavigate();
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo/logo.png', height: 120),
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }
}
