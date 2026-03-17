import 'package:flutter/material.dart';
import 'package:helpflutter/core/theme/theme.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';
import 'package:helpflutter/data/repositories/dependent_repository.dart';
import 'package:helpflutter/data/repositories/live_report_repository.dart';
import 'package:helpflutter/data/repositories/tutorial_repository.dart';
import 'package:helpflutter/data/repositories/profile_repository.dart';
import 'package:helpflutter/presentation/routes/app_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
