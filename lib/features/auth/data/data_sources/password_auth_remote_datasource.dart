
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordAuthRemoteDatasource {
  final Dio dio;
  final FirebaseAuth firebaseAuth;

  PasswordAuthRemoteDatasource({
    required this.dio,
    required this.firebaseAuth,
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

    final customToken = response.data?['customToken'];

    if (customToken is! String || customToken.isEmpty) {
      throw const FormatException(
        'Authentication token is missing',
      );
    }

    await firebaseAuth.signInWithCustomToken(customToken);
  }
}
