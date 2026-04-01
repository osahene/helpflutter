import 'package:dio/dio.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/core/constants/secure_storage.dart';

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
          await SecureStorage.clearTokens();
          // Optionally notify user to login again
        }
      }
    }
    handler.next(err);
  }
}
