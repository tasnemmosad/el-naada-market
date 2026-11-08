
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:el_nada_market/core/errors/failure.dart';
import 'package:el_nada_market/features/auth/data/data_sources/password_auth_remote_datasource.dart';
import 'package:el_nada_market/features/auth/domain/repos/password_auth_repo.dart';

class PasswordAuthRepoImpl implements PasswordAuthRepo {
  final PasswordAuthRemoteDatasource remoteDatasource;

  PasswordAuthRepoImpl({
    required this.remoteDatasource,
  });

  @override
  Future<Either<Failure, void>> register({
    required String phone,
    required String password,
  }) {
    return _execute(
      () => remoteDatasource.register(
        phone: phone,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> login({
    required String phone,
    required String password,
  }) {
    return _execute(
      () => remoteDatasource.login(
        phone: phone,
        password: password,
      ),
    );
  }

  Future<Either<Failure, void>> _execute(
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
      return const Right(null);

    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] is String) {
        return Left(
          AuthFailure(data['message'] as String),
        );
      }

      return Left(
        AuthFailure(
          'تعذر الاتصال بالخدمة. يرجى المحاولة مرة أخرى.',
        ),
      );

    } on FormatException {
      return Left(
        AuthFailure(
          'استجابة غير صحيحة من الخادم.',
        ),
      );

    } catch (_) {
      return Left(
        AuthFailure(
          'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
        ),
      );
    }
  }
}
