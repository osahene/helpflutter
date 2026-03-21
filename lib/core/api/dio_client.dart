import 'package:dio/dio.dart';
import 'package:helpflutter/core/api/api_constants.dart';
import 'package:helpflutter/core/api/token_manager.dart';

class DioClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'X-API-KEY': ApiConstants.apiKey,
      },
    ),
  );

  static Dio get instance {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
    return _dio;
  }

  static Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokenManager = TokenManager();
    await tokenManager.loadTokens();
    final token = tokenManager.accessToken;

    if (token != null && !tokenManager.isAccessTokenExpired()) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  static void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // You can add global response handling (e.g., logging, loading indicator)
    return handler.next(response);
  }

  static Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      final tokenManager = TokenManager();
      await tokenManager.loadTokens();
      final refreshToken = tokenManager.refreshToken;

      if (refreshToken != null) {
        try {
          // Create a fresh Dio instance for refresh (avoid recursion)
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              headers: {
                'Content-Type': 'application/json',
                'X-API-KEY': ApiConstants.apiKey,
              },
            ),
          );
          final response = await refreshDio.post(
            ApiConstants.refreshToken,
            data: {'refresh': refreshToken},
          );
          if (response.statusCode == 200) {
            final newAccess = response.data['access'];
            final newRefresh = response.data['refresh'] ?? refreshToken;
            await tokenManager.setTokens(newAccess, newRefresh);
            // Retry the original request with new token
            final options = error.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccess';
            final retryResponse = await _dio.fetch(options);
            return handler.resolve(retryResponse);
          } else {
            // Refresh failed – clear tokens
            await tokenManager.clearTokens();
            // Optionally trigger logout event
          }
        } catch (e) {
          await tokenManager.clearTokens();
        }
      } else {
        await tokenManager.clearTokens();
      }
    }
    return handler.next(error);
  }
}
