import 'dart:async';
import 'package:dio/dio.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/core/constants/secure_storage.dart';

class ApiClient {
  static final _logoutController = StreamController<void>.broadcast();
  static Stream<void> get logoutStream => _logoutController.stream;

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const String apiKey = String.fromEnvironment(
    'FRONTEND_API_KEY',
    defaultValue: 'your-api-key-here', // replace with actual key
  );

  static final Dio _dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': apiKey, // if required by backend
        },
      ),
    );
    dio.interceptors.add(AuthInterceptor());
    return dio;
  }

  static Dio get instance => _dio;
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await SecureStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != AppConstants.refreshToken) {
      // Attempt refresh token
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: ApiClient.baseUrl,
              headers: {'X-API-Key': ApiClient.apiKey},
            ),
          );

          final response = await refreshDio.post(
            AppConstants.refreshToken,
            data: {'refresh': refreshToken},
          );

          final newAccessToken = response.data['access'];
          await SecureStorage.saveAccessToken(newAccessToken);
          // Retry original request

          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryResponse = await ApiClient.instance.fetch(opts);
          return handler.resolve(retryResponse);
        } catch (e) {
          // Refresh failed, logout
          await SecureStorage.clearTokens();
          await SecureStorage.setLoggedIn(false);
          ApiClient._logoutController.add(null);

          return handler.reject(err);
          // You might want to emit a logout event via BLoC
        }
      }
    }
    handler.next(err);
  }
}
