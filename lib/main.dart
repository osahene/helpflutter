import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/core/theme/theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:helpflutter/core/constants/api_service.dart';
import 'package:helpflutter/data/repositories/auth_repository.dart';
import 'package:helpflutter/data/repositories/alert_repository.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';
import 'package:helpflutter/data/repositories/dependent_repository.dart';
import 'package:helpflutter/data/repositories/profile_repository.dart';
import 'package:helpflutter/data/repositories/live_report_repository.dart';
import 'package:helpflutter/data/repositories/tutorial_repository.dart';
import 'package:helpflutter/logic/alert/alert_bloc.dart';
import 'package:helpflutter/logic/auth/auth_bloc.dart';
import 'package:helpflutter/logic/contacts/contacts_bloc.dart';
import 'package:helpflutter/logic/profile/profile_bloc.dart';
import 'package:helpflutter/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:helpflutter/presentation/screens/auth/login_screen.dart';
import 'package:helpflutter/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:helpflutter/core/constants/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  final isLoggedIn = await SecureStorage.isLoggedIn();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");

  runApp(
    MyApp(
      hasSeenOnboarding: hasSeenOnboarding,
      isLoggedIn: isLoggedIn,
      widgetsBinding: widgetsBinding,
    ),
  );
}

// 1. Changed to StatefulWidget to support initState()
class MyApp extends StatefulWidget {
  final bool hasSeenOnboarding;
  final bool isLoggedIn;
  final WidgetsBinding widgetsBinding;

  const MyApp({
    super.key,
    required this.hasSeenOnboarding,
    required this.isLoggedIn,
    required this.widgetsBinding,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    initialization();
  }

  void initialization() async {
    await Future.delayed(const Duration(seconds: 1));
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(apiService: _apiService),
        ),
        RepositoryProvider<AlertRepository>(
          create: (context) => AlertRepositoryImpl(apiService: _apiService),
        ),
        RepositoryProvider<ContactRepository>(
          create: (context) => ContactRepositoryImpl(apiService: _apiService),
        ),
        RepositoryProvider<DependentRepository>(
          create: (context) => DependentRepositoryImpl(apiService: _apiService),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepositoryImpl(apiService: _apiService),
        ),
        RepositoryProvider<LiveReportRepository>(
          create: (context) => MockLiveReportRepository(),
        ),
        RepositoryProvider<TutorialRepository>(
          create: (context) => MockTutorialRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // 2. Now the Blocs can "read" the repositories from the context
          BlocProvider(
            create: (context) =>
                AuthBloc(repository: context.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                ProfileBloc(repository: context.read<ProfileRepository>())
                  ..add(LoadProfile()),
          ),
          BlocProvider(
            // 3. Fixed positional to named parameter `repository:`
            create: (context) =>
                ContactsBloc(repository: context.read<ContactRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                AlertBloc(repository: context.read<AlertRepository>()),
          ),
        ],
        child: MaterialApp(
          title: 'Help Oo Help',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              // If the Bloc explicitly says unauthenticated (Logged Out)
              if (state is AuthUnauthenticated) {
                return const LoginScreen();
              }

              // If the Bloc explicitly says authenticated (Logged In)
              if (state is AuthAuthenticated) {
                return const DashboardScreen();
              }

              // Default startup logic (Checks SharedPreferences / SecureStorage)
              if (!widget.hasSeenOnboarding) {
                return const OnboardingScreen();
              } else if (!widget.isLoggedIn) {
                return const LoginScreen();
              } else {
                return const DashboardScreen();
              }
            },
          ),
        ),
      ),
    );
  }

  // Widget _getInitialScreen() {
  //   if (!widget.hasSeenOnboarding) {
  //     // Added 'widget.' prefix to access properties
  //     return const OnboardingScreen();
  //   } else if (!widget.isLoggedIn) {
  //     // Added 'widget.' prefix
  //     return const LoginScreen();
  //   } else {
  //     return const DashboardScreen();
  //   }
  // }
}
