
import 'package:dartz/dartz.dart';

import 'package:el_nada_market/core/errors/failure.dart';
import 'package:el_nada_market/features/profile/domain/entities/customer_profile.dart';

abstract class ProfileRepo {
  Future<Either<Failure, CustomerProfile?>> getProfile();

  Future<Either<Failure, void>> updateProfile({
    required String name,
    required String address,
    String? phone2,
    required String paymentMethod,
  });
}
