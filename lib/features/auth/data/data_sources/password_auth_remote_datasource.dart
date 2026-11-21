// // import 'package:dio/dio.dart';
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// // class PasswordAuthRemoteDatasource {
// //   final Dio dio;
// //   final FlutterSecureStorage secureStorage;

// //   PasswordAuthRemoteDatasource({
// //     required this.dio,
// //     required this.secureStorage,
// //   });

// //   Future<void> register({
// //     required String phone,
// //     required String password,
// //   }) async {
// //     await _authenticate(
// //       endpoint: '/auth/register',
// //       phone: phone,
// //       password: password,
// //     );
// //   }

// //   Future<void> login({required String phone, required String password}) async {
// //     await _authenticate(
// //       endpoint: '/auth/login',
// //       phone: phone,
// //       password: password,
// //     );
// //   }

// //   Future<void> _authenticate({
// //     required String endpoint,
// //     required String phone,
// //     required String password,
// //   }) async {
// //     final response = await dio.post<Map<String, dynamic>>(
// //       endpoint,
// //       data: {'phone': phone, 'password': password},
// //     );

// //     final data = response.data;
// //     final token = data?['token'];

// //     if (token is! String || token.isEmpty) {
// //       throw const FormatException('Authentication token is missing');
// //     }

// //     // Save JWT securely on the device.
// //     await secureStorage.write(key: 'auth_token', value: token);
// //   }

// //   Future<void> logout() async {
// //     await secureStorage.delete(key: 'auth_token');
// //   }
// // }

// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class PasswordAuthRemoteDatasource {
//   final Dio dio;
//   final FlutterSecureStorage secureStorage;

//   PasswordAuthRemoteDatasource({
//     required this.dio,
//     required this.secureStorage,
//   });

//   Future<void> register({
//     required String nickname,
//     required String phone,
//     required String password,
//   }) async {
//     await _authenticate(
//       endpoint: '/auth/register',
//       phone: phone,
//       password: password,
//       nickname: nickname,
//     );
//   }

//   Future<void> login({required String phone, required String password}) async {
//     await _authenticate(
//       endpoint: '/auth/login',
//       phone: phone,
//       password: password,
//     );
//   }

//   Future<void> _authenticate({
//     required String endpoint,
//     required String phone,
//     required String password,
//     String? nickname,
//   }) async {
//     final response = await dio.post<Map<String, dynamic>>(
//       endpoint,
//       data: {
//         'phone': phone,
//         'password': password,
//         ...?(nickname == null ? null : {'nickname': nickname}),
//       },
//     );

//     final data = response.data;
//     final token = data?['token'];

//     if (token is! String || token.isEmpty) {
//       throw const FormatException('Authentication token is missing');
//     }

//     // Save JWT securely on the device.
//     await secureStorage.write(key: 'auth_token', value: token);
//   }

//   Future<void> logout() async {
//     await secureStorage.delete(key: 'auth_token');
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:el_nada_market/features/auth/domain/entities/auth_user.dart';

class PasswordAuthRemoteDatasource {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  PasswordAuthRemoteDatasource({
    required this.dio,
    required this.secureStorage,
  });

  // REGISTER
  Future<void> register({
    required String nickname,
    required String phone,
    required String password,
  }) async {
    await _authenticate(
      endpoint: '/auth/register',
      phone: phone,
      password: password,
      nickname: nickname,
    );
  }

  // LOGIN
  Future<AuthUser> login({
    required String phone,
    required String password,
  }) async {
    final data = await _authenticate(
      endpoint: '/auth/login',
      phone: phone,
      password: password,
    );

    final userData = data['user'];

    if (userData is! Map<String, dynamic>) {
      throw const FormatException('User data is missing');
    }

    final id = userData['id'];
    final userPhone = userData['phone'];
    final nickname = userData['nickname'];
    final type = userData['type'];

    if (id is! int ||
        userPhone is! String ||
        nickname is! String ||
        type is! String) {
      throw const FormatException('Invalid user data');
    }

    return AuthUser(
      id: id,
      phone: userPhone,
      nickname: nickname,
      type: type,
    );
  }

  // SHARED AUTHENTICATION
  Future<Map<String, dynamic>> _authenticate({
    required String endpoint,
    required String phone,
    required String password,
    String? nickname,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      endpoint,
      data: {
        'phone': phone,
        'password': password,
        if (nickname != null) 'nickname': nickname,
      },
    );

    final data = response.data;

    if (data == null) {
      throw const FormatException('Invalid server response');
    }

    final token = data['token'];

    if (token is! String || token.isEmpty) {
      throw const FormatException('Authentication token is missing');
    }

    // Save JWT securely on the device.
    await secureStorage.write(
      key: 'auth_token',
      value: token,
    );

    return data;
  }

  // LOGOUT
  Future<void> logout() async {
    await secureStorage.delete(key: 'auth_token');
  }
}
