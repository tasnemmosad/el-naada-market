
import 'package:dartz/dartz.dart';

import 'package:el_nada_market/core/errors/failure.dart';
import 'package:el_nada_market/features/profile/domain/repos/profile_repo.dart';

class UpdateProfileUsecase {
  final ProfileRepo repo;

  UpdateProfileUsecase({
    required this.repo,
  });

  Future<Either<Failure, void>> call({
    required String name,
    required String address,
    String? phone2,
    required String paymentMethod,
  }) {
    return repo.updateProfile(
      name: name,
      address: address,
      phone2: phone2,
      paymentMethod: paymentMethod,
    );
  }
}
