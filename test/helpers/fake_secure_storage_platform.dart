import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';

/// In-memory stand-in for the real secure-storage platform implementation.
///
/// On Windows, flutter_secure_storage talks to the native Credential Manager
/// over FFI rather than a mockable MethodChannel — under `flutter test`'s
/// headless binding (no real message loop), those calls hang indefinitely
/// instead of failing fast. Any code that awaits SecureStorage (AuthBloc's
/// AuthCheckRequested handler, for one) hangs the test without this override.
/// Install it once per test file with:
///   setUp(() => FlutterSecureStoragePlatform.instance = FakeSecureStoragePlatform());
class FakeSecureStoragePlatform extends FlutterSecureStoragePlatform {
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
