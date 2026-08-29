import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:helpflutter/core/theme/theme.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
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
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  final isLoggedIn = await SecureStorage.isLoggedIn();

  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Never blocks/crashes app start — see PushService's own doc comment.
  // There's no Firebase project configured yet, so this will fail and
  // leave PushService.isAvailable false until one is added.
  await PushService.initialize(navigatorKey);

  // Crashlytics relies on the same Firebase project as PushService. If
  // Firebase.initializeApp() above failed, PushService.isAvailable stays
  // false and we skip wiring Crashlytics entirely rather than let it throw
  // on an uninitialized Firebase app — crash reporting is purely additive
  // and must never itself be the reason the app fails to start.
  if (PushService.isAvailable) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Never blocks/crashes app start — see PushService's own doc comment.
  // There's no Firebase project configured yet, so this will fail and
  // leave PushService.isAvailable false until one is added.
  await PushService.initialize(navigatorKey);

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
          create: (context) => LiveReportRepositoryImpl(apiService: _apiService),
        ),
        RepositoryProvider<AgencyRepository>(
          create: (context) => AgencyRepositoryImpl(apiService: _apiService),
        ),
        RepositoryProvider<TitbitRepository>(
          create: (context) => TitbitRepositoryImpl(apiService: _apiService),
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
                AuthBloc(repository: context.read<AuthRepository>())
                  ..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) =>
                ProfileBloc(repository: context.read<ProfileRepository>()),
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
                // Fire-and-forget: registers this device's FCM token once
                // signed in (covers both a fresh login and an already-
                // logged-in cold start). No-op if Firebase isn't set up.
                PushService.registerDeviceToken(context.read<TitbitRepository>());
              } else if (state is AuthUnauthenticated) {
                context.read<ProfileBloc>().add(
                  ClearProfile(),
                ); // add this event
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

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
