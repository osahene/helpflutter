import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:helpflutter/core/theme/theme.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';
import 'package:helpflutter/data/repositories/dependent_repository.dart';
import 'package:helpflutter/data/repositories/live_report_repository.dart';
import 'package:helpflutter/data/repositories/tutorial_repository.dart';
import 'package:helpflutter/data/repositories/profile_repository.dart';
import 'package:helpflutter/data/repositories/alert_repository.dart';
import 'package:helpflutter/presentation/routes/app_router.dart';
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
    // This is where you could load user data, check login status, etc.
    // For now, we'll just wait a brief moment to ensure everything is ready.
    await Future.delayed(const Duration(seconds: 1));

    // This is the line you were missing!
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide repositories
        Provider<ContactRepository>(create: (_) => MockContactRepository()),
        Provider<DependentRepository>(create: (_) => MockDependentRepository()),
        Provider<LiveReportRepository>(
          create: (_) => MockLiveReportRepository(),
        ),
        Provider<TutorialRepository>(create: (_) => MockTutorialRepository()),
        Provider<ProfileRepository>(create: (_) => MockProfileRepository()),

        // FIXED: Replaced constructor signature with actual instantiation
        Provider<AlertRepository>(
          create: (_) => AlertRepositoryImpl(
            baseUrl:
                'https://your-production-backend.com/api', // <-- Insert your actual API base URL here
          ),
        ),
        // Add other repositories if needed
      ],
      child: MaterialApp(
        title: 'Help Oo Help',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRouter.home,
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
