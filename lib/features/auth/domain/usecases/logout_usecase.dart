import 'package:dartz/dartz.dart';

import 'package:el_nada_market/core/errors/failure.dart';
import 'package:el_nada_market/features/auth/domain/repos/password_auth_repo.dart';

class LogoutUsecase {
  final PasswordAuthRepo repo;

  LogoutUsecase({required this.repo});

  Future<Either<Failure, void>> call() {
    return repo.logout();
  }
}
