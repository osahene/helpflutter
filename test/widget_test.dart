import 'package:flutter_test/flutter_test.dart';
import 'package:helpflutter/main.dart';
import 'package:helpflutter/presentation/screens/auth/login_screen.dart';

void main() {
  testWidgets('App displays LoginScreen when not logged in', (
    WidgetTester tester,
  ) async {
    // 1. Create a dummy WidgetsBinding for the test
    final widgetsBinding = TestWidgetsFlutterBinding.ensureInitialized();

    // 2. Build our app with the required parameters
    // We simulate a user who has seen onboarding but is NOT logged in
    await tester.pumpWidget(
      MyApp(
        hasSeenOnboarding: true,
        isLoggedIn: false,
        widgetsBinding: widgetsBinding,
      ),
    );

    // 3. Wait for the splash delay and animations to settle
    await tester.pumpAndSettle();

    // 4. Verify that the LoginScreen is present
    expect(find.byType(LoginScreen), findsOneWidget);

    // 5. You can also check for specific text unique to your login screen
    // Example: expect(find.text('Login'), findsOneWidget);
  });
}
