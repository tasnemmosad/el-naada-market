
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'package:el_nada_market/core/errors/failure.dart';
import 'package:el_nada_market/features/profile/data/data_sources/profile_remote_datasource.dart';
import 'package:el_nada_market/features/profile/domain/entities/customer_profile.dart';
import 'package:el_nada_market/features/profile/domain/repos/profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ProfileRemoteDatasource remoteDatasource;

  ProfileRepoImpl({
    required this.remoteDatasource,
  });

  @override
  Future<Either<Failure, CustomerProfile?>> getProfile() {
    return _execute(() => remoteDatasource.getProfile());
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    required String name,
    required String address,
    String? phone2,
    required String paymentMethod,
  }) {
    return _execute(
      () => remoteDatasource.updateProfile(
        name: name,
        address: address,
        phone2: phone2,
        paymentMethod: paymentMethod,
      ),
    );
  }

  Future<Either<Failure, T>> _execute<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Right(result);
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data['message'] is String) {
        return Left(AuthFailure(data['message'] as String));
      }

      return Left(
        AuthFailure('تعذر الاتصال بالخدمة. يرجى المحاولة مرة أخرى.'),
      );
    } on FormatException {
      return Left(
        AuthFailure('استجابة غير صحيحة من الخادم.'),
      );
    } catch (_) {
      return Left(
        AuthFailure('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.'),
      );
    }
  }
}
