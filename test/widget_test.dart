import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpflutter/main.dart';
import 'package:helpflutter/presentation/screens/auth/login_screen.dart';

import 'helpers/fake_secure_storage_platform.dart';

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = FakeSecureStoragePlatform();
  });

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

    // 3. Wait for the splash delay and the async auth check to resolve.
    //
    // Deliberately NOT pumpAndSettle(): AuthInitial renders a
    // CircularProgressIndicator (indeterminate), whose own animation
    // controller schedules a new frame every tick for as long as it's
    // mounted — pumpAndSettle has no way to tell "still waiting on real
    // async work" apart from "just a spinner that animates forever", so it
    // would time out here regardless of how fast the auth check resolves.
    // A bounded pump sequence sidesteps that entirely.
    await tester.pump(); // build AuthInitial / the splash screen
    await tester.pump(const Duration(seconds: 2)); // let AuthCheckRequested resolve

    // 4. Verify that the LoginScreen is present
    expect(find.byType(LoginScreen), findsOneWidget);

    // 5. You can also check for specific text unique to your login screen
    // Example: expect(find.text('Login'), findsOneWidget);
  });
}
