import 'package:flutter_test/flutter_test.dart';
import 'package:helpflutter/core/constants/api_client.dart';

// Regression coverage for the bug that used to make every build silently
// unable to reach the backend: nothing in this repo ever passed
// --dart-define, so ApiClient fell back to the Android emulator loopback
// with a literal placeholder API key. baseUrl now defaults to the real
// production backend (safe to bake in — it's a public HTTPS domain, not a
// secret) and a missing apiKey is a loud, immediate failure instead of a
// silently-broken one.
void main() {
  test('baseUrl defaults to the real production backend over HTTPS', () {
    expect(ApiClient.baseUrl, 'https://emergencysystem.onrender.com');
    expect(ApiClient.baseUrl, startsWith('https://'));
    // Never again silently fall back to an address only reachable from an
    // emulator/local machine.
    expect(ApiClient.baseUrl, isNot(contains('10.0.2.2')));
    expect(ApiClient.baseUrl, isNot(contains('127.0.0.1')));
    expect(ApiClient.baseUrl, isNot(contains('localhost')));
  });

  test('assertConfigured() fails loudly instead of shipping a placeholder key', () {
    // `flutter test` runs with no --dart-define, so apiKey is empty here —
    // exactly the "nobody passed the flag" scenario that used to silently
    // send a broken placeholder in production.
    expect(ApiClient.apiKey, isEmpty);
    expect(ApiClient.assertConfigured, throwsA(isA<StateError>()));
  });
}
