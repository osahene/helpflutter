import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helpflutter/core/constants/api_client.dart';
import 'package:helpflutter/core/constants/secure_storage.dart';
import 'package:helpflutter/data/models/user.dart';
import 'package:helpflutter/data/repositories/auth_repository.dart';
import 'package:helpflutter/logic/auth/auth_bloc.dart';

import '../../helpers/fake_secure_storage_platform.dart';

/// Hand-rolled fake — no mocking package needed for an interface this
/// small. `getProfileCalls` lets tests assert the AuthCheckRequested cache
/// short-circuit (a cached user must skip the network call entirely).
class FakeAuthRepository implements AuthRepository {
  User? profileToReturn;
  Object? profileError;
  int getProfileCalls = 0;

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String phoneNumber,
    required bool agreedToTerms,
  }) async {}

  @override
  Future<void> sendOtp({
    required String countryCode,
    required String phoneNumber,
  }) async {}

  ({User user, String token, String refresh})? verifyOtpResult;
  Object? verifyOtpError;

  @override
  Future<({User user, String token, String refresh})> verifyOtp({
    required String countryCode,
    required String phoneNumber,
    required String otp,
  }) async {
    if (verifyOtpError != null) throw verifyOtpError!;
    return verifyOtpResult!;
  }

  @override
  Future<void> logout(String refreshToken) async {}

  @override
  Future<User> getProfile() async {
    getProfileCalls++;
    if (profileError != null) throw profileError!;
    return profileToReturn!;
  }
}

User buildUser({String id = 'u1'}) =>
    User(id: id, firstName: 'Ama', lastName: 'Owusu', fullName: 'Ama Owusu');

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = FakeSecureStoragePlatform();
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits AuthUnauthenticated when there is no stored session',
      build: () => AuthBloc(repository: FakeAuthRepository()),
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
    );

    test('cached user short-circuits the getProfile() network call', () async {
      await SecureStorage.saveAccessToken('access');
      await SecureStorage.saveRefreshToken('refresh');
      await SecureStorage.saveUser(buildUser());
      final repo = FakeAuthRepository();

      final bloc = AuthBloc(repository: repo);
      bloc.add(AuthCheckRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<AuthAuthenticated>());
      expect(repo.getProfileCalls, 0);
      await bloc.close();
    });

    test('falls back to getProfile() when nothing is cached, then caches it', () async {
      await SecureStorage.saveAccessToken('access');
      await SecureStorage.saveRefreshToken('refresh');
      final repo = FakeAuthRepository()..profileToReturn = buildUser(id: 'from-network');

      final bloc = AuthBloc(repository: repo);
      bloc.add(AuthCheckRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<AuthAuthenticated>());
      expect((bloc.state as AuthAuthenticated).user.id, 'from-network');
      expect(repo.getProfileCalls, 1);
      expect((await SecureStorage.getCachedUser())?.id, 'from-network');
      await bloc.close();
    });

    test('clears the session and goes unauthenticated when getProfile() fails', () async {
      await SecureStorage.saveAccessToken('access');
      await SecureStorage.saveRefreshToken('refresh');
      final repo = FakeAuthRepository()..profileError = Exception('401');

      final bloc = AuthBloc(repository: repo);
      bloc.add(AuthCheckRequested());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<AuthUnauthenticated>());
      expect(await SecureStorage.getAccessToken(), isNull);
      await bloc.close();
    });
  });

  group('AuthVerifyOtpRequested', () {
    blocTest<AuthBloc, AuthState>(
      'saves the session and emits AuthAuthenticated on success',
      build: () {
        final repo = FakeAuthRepository()
          ..verifyOtpResult = (
            user: buildUser(),
            token: 'access-token',
            refresh: 'refresh-token',
          );
        return AuthBloc(repository: repo);
      },
      act: (bloc) => bloc.add(
        const AuthVerifyOtpRequested(
          countryCode: '+233',
          phoneNumber: '549247604',
          otp: '1234',
        ),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
      verify: (_) async {
        expect(await SecureStorage.getAccessToken(), 'access-token');
        expect(await SecureStorage.getRefreshToken(), 'refresh-token');
        expect(await SecureStorage.isLoggedIn(), isTrue);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits AuthError and stores nothing on failure',
      build: () {
        final repo = FakeAuthRepository()..verifyOtpError = Exception('bad otp');
        return AuthBloc(repository: repo);
      },
      act: (bloc) => bloc.add(
        const AuthVerifyOtpRequested(
          countryCode: '+233',
          phoneNumber: '549247604',
          otp: '0000',
        ),
      ),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      verify: (_) async {
        expect(await SecureStorage.getAccessToken(), isNull);
      },
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'clears the session and emits AuthUnauthenticated',
      setUp: () async {
        await SecureStorage.saveAccessToken('access');
        await SecureStorage.saveRefreshToken('refresh');
        await SecureStorage.setLoggedIn(true);
      },
      build: () => AuthBloc(repository: FakeAuthRepository()),
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [isA<AuthUnauthenticated>()],
      verify: (_) async {
        expect(await SecureStorage.isLoggedIn(), isFalse);
        expect(await SecureStorage.getAccessToken(), isNull);
      },
    );

    test('ApiClient.logoutStream automatically triggers a logout', () async {
      await SecureStorage.saveAccessToken('access');
      await SecureStorage.setLoggedIn(true);
      final bloc = AuthBloc(repository: FakeAuthRepository());

      ApiClient.debugFireLogout();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<AuthUnauthenticated>());
      expect(await SecureStorage.isLoggedIn(), isFalse);
      await bloc.close();
    });
  });
}
