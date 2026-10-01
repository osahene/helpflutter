import 'dart:async';
import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:meta/meta.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/core/constants/secure_storage.dart';

class ApiClient {
  static final _logoutController = StreamController<void>.broadcast();
  static Stream<void> get logoutStream => _logoutController.stream;

  @visibleForTesting
  static void debugFireLogout() => _logoutController.add(null);

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://emergencysystem.onrender.com',
  );

  static const String apiKey = String.fromEnvironment('FRONTEND_API_KEY');

  static void assertConfigured() {
    if (apiKey.isEmpty) {
      throw StateError(
        'FRONTEND_API_KEY was not provided at build time. Build with '
        '--dart-define-from-file=.env (see README.md "Configuration") — '
        'never hardcode the real key in source.',
      );
    }
  }

  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'X-API-Key': apiKey},
        extra: {
          'withCredentials': true,
        }, // Ensure cookies are sent with requests
      ),
    );
    // final cookieJar = PersistCookieJar(
    //   storage: FileStorage(AppConstants.refreshToken), // Provide a path
    // );
    // dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(AuthInterceptor());
    return dio;
  }

  static Dio get instance => _dio;
}

class AuthInterceptor extends Interceptor {
  static Completer<String?>? _refreshCompleter;

  bool _isAuthPath(String path) =>
      path.contains(AppConstants.refreshToken) ||
      path.contains(AppConstants.sendOtp) ||
      path.contains(AppConstants.verifyOtp) ||
      path.contains(AppConstants.login);

  // Session validity is judged from the token itself, proactively, here —
  // not reactively from whatever status code a response happens to carry.
  // This used to only attach whatever was in storage and rely entirely on
  // onError's 401 handling below, which meant every request with an
  // already-expired token cost a guaranteed failed round trip before the
  // retry-after-refresh ever kicked in.
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthPath(options.path)) {
      final token = await SecureStorage.getAccessToken();
      if (token != null) {
        if (!_isExpired(token)) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          final newToken = await _refresh();
          if (newToken != null) {
            options.headers['Authorization'] = 'Bearer $newToken';
          }
          // else: refresh was inconclusive (network blip) or the session is
          // confirmed dead (_refresh() already fired the logout stream in
          // that case). Either way, let this one request go out without a
          // fresh token rather than blocking it entirely — onError below is
          // still there to catch the 401 it'll likely get.
        }
      }
    }
    handler.next(options);
  }

  static bool _isExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (_) {
      // Undecodable/malformed — treat as expired so it goes through the
      // refresh path instead of being sent as-is.
      return true;
    }
  }

  // Backstop for whatever the proactive check above didn't catch (clock
  // skew against the server, or the token expiring in the moment between
  // that check and the server actually seeing the request).
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 ||
        _isAuthPath(err.requestOptions.path)) {
      return handler.next(err);
    }

    final newToken = await _refresh();
    if (newToken == null) return handler.reject(err);

    try {
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      return handler.resolve(await ApiClient.instance.fetch(opts));
    } catch (_) {
      return handler.reject(err);
    }
  }

  static Future<String?> _refresh() {
    // every concurrent 401 awaits the SAME refresh call
    if (_refreshCompleter != null) return _refreshCompleter!.future;

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    () async {
      try {
        final refreshToken = await SecureStorage.getRefreshToken();
        if (refreshToken == null) {
          // Nothing to retry with — the session is genuinely over.
          await SecureStorage.clearSession();
          ApiClient._logoutController.add(null);
          completer.complete(null);
          return;
        }

        final refreshDio = Dio(
          BaseOptions(
            baseUrl: ApiClient.baseUrl,
            headers: {
              'Content-Type': 'application/json',
              'X-API-Key': ApiClient.apiKey,
            },
          ),
        );

        final res = await refreshDio.post(
          AppConstants.refreshToken,
          data: {'refresh': refreshToken},
        );

        final access = res.data['access'] as String?;
        final rotated = res.data['refresh'] as String?;
        if (access == null) {
          // The server answered but not with what we expected — a bug
          // somewhere, not proof the refresh token itself is dead. Don't
          // tear down a session that might still be perfectly valid.
          completer.complete(null);
          return;
        }

        await SecureStorage.saveAccessToken(access);
        if (rotated != null) {
          await SecureStorage.saveRefreshToken(rotated); // ← THE fix for (a)
        }
        completer.complete(access);
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        // SimpleJWT's own rejection of a dead refresh token carries
        // {"detail": "...", "code": "token_not_valid"} — that specific
        // shape is the only thing that means "this token is genuinely
        // dead." A 401 can also come from
        // EmergencyBackend/frontend_api_key_middleware.py (a
        // misconfigured/mismatched FRONTEND_API_KEY — see
        // ApiClient.apiKey), which returns a 401 with no "code" field at
        // all. That's a deployment/config problem, not an expired session,
        // and it would hit *every* request — treating it as "session dead"
        // would force-logout every session the moment the key drifts out
        // of sync, which is worse than just failing the one call.
        final body = e.response?.data;
        final code = body is Map ? body['code'] : null;
        if ((status == 401 || status == 403) && code == 'token_not_valid') {
          // The server explicitly rejected this refresh token — it's
          // genuinely dead (expired/blacklisted/revoked). No amount of
          // retrying helps.
          await SecureStorage.clearSession();
          ApiClient._logoutController.add(null);
        }
        // Everything else — no connection, a timeout, a 5xx, a cold-started
        // backend still waking up — is not proof the refresh token is bad.
        // A network blip must never log out a session that's still
        // perfectly valid; this one request just fails, and the next
        // request gets another chance to refresh.
        completer.complete(null);
      } catch (_) {
        completer.complete(null);
      } finally {
        _refreshCompleter = null;
      }
    }();

    return completer.future;
  }
}
