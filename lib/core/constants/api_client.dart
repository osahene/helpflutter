import 'dart:async';
import 'package:dio/dio.dart';
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

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthPath(options.path)) {
      final token = await SecureStorage.getAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

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
        if (refreshToken == null) throw Exception('no refresh token');

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
        if (access == null) throw Exception('malformed refresh response');

        await SecureStorage.saveAccessToken(access);
        if (rotated != null) {
          await SecureStorage.saveRefreshToken(rotated); // ← THE fix for (a)
        }
        completer.complete(access);
      } catch (_) {
        await SecureStorage.clearSession();
        ApiClient._logoutController.add(null);
        completer.complete(null);
      } finally {
        _refreshCompleter = null;
      }
    }();

    return completer.future;
  }
}
