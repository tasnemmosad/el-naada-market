
import 'package:dartz/dartz.dart';

import 'package:el_nada_market/core/errors/failure.dart';
import 'package:el_nada_market/features/profile/domain/entities/customer_profile.dart';
import 'package:el_nada_market/features/profile/domain/repos/profile_repo.dart';

class GetProfileUsecase {
  final ProfileRepo repo;

  GetProfileUsecase({
    required this.repo,
  });

  Future<Either<Failure, CustomerProfile?>> call() {
    return repo.getProfile();
  }
}
