import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:helpflutter/core/theme/theme.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:helpflutter/core/constants/api_client.dart';
import 'package:helpflutter/core/constants/api_service.dart';
import 'package:helpflutter/core/services/push_service.dart';
import 'package:helpflutter/data/repositories/auth_repository.dart';
import 'package:helpflutter/data/repositories/alert_repository.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';
import 'package:helpflutter/data/repositories/dependent_repository.dart';
import 'package:helpflutter/data/repositories/profile_repository.dart';
import 'package:helpflutter/data/repositories/live_report_repository.dart';
import 'package:helpflutter/data/repositories/agency_repository.dart';
import 'package:helpflutter/data/repositories/titbit_repository.dart';
import 'package:helpflutter/data/repositories/tutorial_repository.dart';
import 'package:helpflutter/data/repositories/incoming_alert_repository.dart';
import 'package:helpflutter/logic/alert/alert_bloc.dart';
import 'package:helpflutter/logic/auth/auth_bloc.dart';
import 'package:helpflutter/logic/contacts/contacts_bloc.dart';
import 'package:helpflutter/logic/profile/profile_bloc.dart';
import 'package:helpflutter/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:helpflutter/presentation/screens/auth/login_screen.dart';
import 'package:helpflutter/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:helpflutter/core/constants/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lets PushService navigate to the Titbit inbox from a notification tap,
/// from outside the widget tree (e.g. a cold-start tap on a push).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  ApiClient.assertConfigured();
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  final isLoggedIn = await SecureStorage.isLoggedIn();

  await PushService.initialize(navigatorKey);

  if (PushService.isAvailable) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(
    MyApp(
      hasSeenOnboarding: hasSeenOnboarding,
      isLoggedIn: isLoggedIn,
      widgetsBinding: widgetsBinding,
    ),
  );
}

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
    // FlutterNativeSplash.remove();
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
          create: (context) =>
              LiveReportRepositoryImpl(apiService: _apiService),
        ),
        RepositoryProvider<AgencyRepository>(
          create: (context) => AgencyRepositoryImpl(apiService: _apiService),
        ),
        RepositoryProvider<TitbitRepository>(
          create: (context) => TitbitRepositoryImpl(apiService: _apiService),
        ),
        RepositoryProvider<IncomingAlertRepository>(
          create: (context) =>
              IncomingAlertRepositoryImpl(apiService: _apiService),
        ),
        RepositoryProvider<TutorialRepository>(
          create: (context) => MockTutorialRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(repository: context.read<AuthRepository>())
                  ..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) =>
                ProfileBloc(repository: context.read<ProfileRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                ContactsBloc(repository: context.read<ContactRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                AlertBloc(repository: context.read<AlertRepository>()),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Help Oo Help',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          home: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                context.read<ProfileBloc>().add(LoadProfile(user: state.user));
                PushService.registerDeviceToken(
                  context.read<TitbitRepository>(),
                );
              } else if (state is AuthUnauthenticated) {
                context.read<ProfileBloc>().add(
                  ClearProfile(),
                ); // add this event
                // Swapping `home`'s content below (Dashboard -> Login) only
                // changes what the *bottom* route shows — any screen the
                // user had pushed on top (a pushed AlertConfirmationScreen,
                // IncomingAlertScreen, a settings page, ...) stays on top of
                // it, hiding the login screen entirely until manually
                // popped. A forced logout (expired/dead refresh token, see
                // ApiClient.logoutStream) needs the user to actually land on
                // LoginScreen, not stay stranded wherever they were.
                navigatorKey.currentState?.popUntil((route) => route.isFirst);
              }
            },
            child: BlocBuilder<AuthBloc, AuthState>(
              // ← the critical guard: transient states must NOT rebuild the root
              buildWhen: (prev, curr) =>
                  curr is AuthAuthenticated ||
                  curr is AuthUnauthenticated ||
                  curr is AuthInitial,
              builder: (context, state) {
                if (state is AuthAuthenticated) return const DashboardScreen();
                if (state is AuthUnauthenticated) {
                  return widget.hasSeenOnboarding
                      ? const LoginScreen()
                      : const OnboardingScreen();
                }
                return const _SplashScreen(); // AuthInitial — still checking storage
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
