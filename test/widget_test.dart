import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpflutter/main.dart';
import 'package:helpflutter/presentation/screens/auth/login_screen.dart';

/// In-memory stand-in for the real secure-storage platform implementation.
///
/// On Windows, flutter_secure_storage talks to the native Credential Manager
/// over FFI rather than a mockable MethodChannel — under `flutter test`'s
/// headless binding (no real message loop), those calls hang indefinitely
/// instead of failing fast. AuthBloc's AuthCheckRequested handler awaits
/// SecureStorage.getAccessToken()/getRefreshToken() before it can emit
/// AuthUnauthenticated, so without this override the widget tree never
/// leaves its loading state and the test times out. This fake keeps
/// everything in memory and never touches a real platform.
class _FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
  final _values = <String, String>{};

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    _values[key] = value;
  }

  @override
  Future<String?> read({
    required String key,
    required Map<String, String> options,
  }) async {
    return _values[key];
  }

  @override
  Future<bool> containsKey({
    required String key,
    required Map<String, String> options,
  }) async {
    return _values.containsKey(key);
  }

  @override
  Future<void> delete({
    required String key,
    required Map<String, String> options,
  }) async {
    _values.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    required Map<String, String> options,
  }) async {
    return Map.of(_values);
  }

  @override
  Future<void> deleteAll({required Map<String, String> options}) async {
    _values.clear();
  }
}

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = _FakeSecureStoragePlatform();
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
