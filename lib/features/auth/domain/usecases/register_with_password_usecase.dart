
// import 'package:dartz/dartz.dart';

// import 'package:el_nada_market/core/errors/failure.dart';
// import 'package:el_nada_market/features/auth/domain/repos/password_auth_repo.dart';

// class RegisterWithPasswordUsecase {
//   final PasswordAuthRepo repo;

//   RegisterWithPasswordUsecase({
//     required this.repo,
//   });

//   Future<Either<Failure, void>> call({
//     required String phone,
//     required String password,
//   }) {
//     return repo.register(
//       phone: phone,
//       password: password,
//     );
//   }
// }

import 'package:dartz/dartz.dart';

import 'package:el_nada_market/core/errors/failure.dart';
import 'package:el_nada_market/features/auth/domain/repos/password_auth_repo.dart';

class RegisterWithPasswordUsecase {
  final PasswordAuthRepo repo;

  RegisterWithPasswordUsecase({
    required this.repo,
  });

  Future<Either<Failure, void>> call({
    required String nickname,
    required String phone,
    required String password,
  }) {
    return repo.register(
      nickname: nickname,
      phone: phone,
      password: password,
    );
  }
}
