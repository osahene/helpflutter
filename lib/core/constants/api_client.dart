import 'package:dio/dio.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/core/constants/interceptor.dart';
import 'package:helpflutter/core/constants/secure_storage.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': AppConstants.apiKey, // if required by backend
      },
    ),
  );

  static Dio get dio {
    _dio.interceptors.clear();
    _dio.interceptors.add(AuthInterceptor());
    return _dio;
  }
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
    if (err.response?.statusCode == 401) {
      // Attempt refresh token
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await Dio().post(
            '${AppConstants.baseUrl}${AppConstants.refreshToken}',
            data: {'refresh': refreshToken},
          );
          final newAccessToken = response.data['access'];
          await SecureStorage.saveAccessToken(newAccessToken);
          // Retry original request
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await Dio().fetch(opts);
          handler.resolve(retryResponse);
          return;
        } catch (e) {
          // Refresh failed, logout
          await SecureStorage.clearTokens();
          // You might want to emit a logout event via BLoC
        }
      }
    }
    handler.next(err);
  }
}
