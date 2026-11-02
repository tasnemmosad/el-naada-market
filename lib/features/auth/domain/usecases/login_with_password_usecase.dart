
import 'package:dartz/dartz.dart';

import 'package:el_nada_market/core/errors/failure.dart';
import 'package:el_nada_market/features/auth/domain/repos/password_auth_repo.dart';

class LoginWithPasswordUsecase {
  final PasswordAuthRepo repo;

  LoginWithPasswordUsecase({
    required this.repo,
  });

  Future<Either<Failure, void>> call({
    required String phone,
    required String password,
  }) {
    return repo.login(
      phone: phone,
      password: password,
    );
  }
}
