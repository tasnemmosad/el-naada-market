
import 'package:dartz/dartz.dart';

import 'package:el_nada_market/core/errors/failure.dart';

abstract class PasswordAuthRepo {
  Future<Either<Failure, void>> register({
    required String phone,
    required String password,
  });

  Future<Either<Failure, void>> login({
    required String phone,
    required String password,
  });
}
