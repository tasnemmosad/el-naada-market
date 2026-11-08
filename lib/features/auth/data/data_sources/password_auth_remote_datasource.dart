
 
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PasswordAuthRemoteDatasource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  PasswordAuthRemoteDatasource({
    required this.dio,
    required this.secureStorage,
  });

  Future<void> register({
    required String phone,
    required String password,
  }) async {
    await _authenticate(
      endpoint: '/auth/register',
      phone: phone,
      password: password,
    );
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    await _authenticate(
      endpoint: '/auth/login',
      phone: phone,
      password: password,
    );
  }

  Future<void> _authenticate({
    required String endpoint,
    required String phone,
    required String password,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      endpoint,
      data: {
        'phone': phone,
        'password': password,
      },
    );

    final data = response.data;
    final token = data?['token'];

    if (token is! String || token.isEmpty) {
      throw const FormatException(
        'Authentication token is missing',
      );
    }

    // Save JWT securely on the device.
    await secureStorage.write(
      key: 'auth_token',
      value: token,
    );
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'auth_token');
  }
}
