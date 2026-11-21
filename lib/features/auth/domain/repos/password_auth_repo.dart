// // import 'package:dartz/dartz.dart';

// // import 'package:el_nada_market/core/errors/failure.dart';

// // abstract class PasswordAuthRepo {
// //   Future<Either<Failure, void>> register({
// //     required String phone,
// //     required String password,
// //   });

// //   Future<Either<Failure, void>> login({
// //     required String phone,
// //     required String password,
// //   });
// //   Future<Either<Failure, void>> logout();
// // }

// import 'package:dartz/dartz.dart';

// import 'package:el_nada_market/core/errors/failure.dart';

// abstract class PasswordAuthRepo {
//   Future<Either<Failure, void>> register({
//     required String nickname,
//     required String phone,
//     required String password,
//   });

//   Future<Either<Failure, void>> login({
//     required String phone,
//     required String password,
//   });

//   Future<Either<Failure, void>> logout();
// }

import 'package:dartz/dartz.dart';

import 'package:el_nada_market/core/errors/failure.dart';
import 'package:el_nada_market/features/auth/domain/entities/auth_user.dart';

abstract class PasswordAuthRepo {
  Future<Either<Failure, void>> register({
    required String nickname,
    required String phone,
    required String password,
  });

  Future<Either<Failure, AuthUser>> login({
    required String phone,
    required String password,
  });

  Future<Either<Failure, void>> logout();
}
