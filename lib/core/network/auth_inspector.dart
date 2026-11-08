
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  AuthInterceptor({
    required this.secureStorage,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final isPublicEndpoint =
          options.path == '/auth/login' ||
          options.path == '/auth/register';

      if (!isPublicEndpoint) {
        final token = await secureStorage.read(
          key: 'auth_token',
        );

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] =
              'Bearer $token';
        }
      }

      handler.next(options);
    } catch (error) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          message: 'Failed to read authentication token',
        ),
      );
    }
  }
}
