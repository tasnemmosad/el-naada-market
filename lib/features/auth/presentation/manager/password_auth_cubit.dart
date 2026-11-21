

// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:el_nada_market/features/auth/domain/usecases/login_with_password_usecase.dart';
// // import 'package:el_nada_market/features/auth/domain/usecases/register_with_password_usecase.dart';
// // import 'package:el_nada_market/features/auth/domain/usecases/logout_usecase.dart';

// // import 'password_auth_state.dart';

// // class PasswordAuthCubit extends Cubit<PasswordAuthState> {
// //   final LoginWithPasswordUsecase loginUsecase;
// //   final RegisterWithPasswordUsecase registerUsecase;
// //   final LogoutUsecase logoutUsecase;

// //   PasswordAuthCubit({
// //     required this.loginUsecase,
// //     required this.registerUsecase,
// //     required this.logoutUsecase,
// //   }) : super(PasswordAuthInitial());

// //   Future<void> login({
// //     required String phone,
// //     required String password,
// //   }) async {
// //     if (state is PasswordAuthLoading) return;

// //     emit(PasswordAuthLoading());

// //     final result = await loginUsecase(
// //       phone: phone,
// //       password: password,
// //     );

// //     if (isClosed) return;

// //     result.fold(
// //       (failure) {
// //         emit(PasswordAuthError(message: failure.message));
// //       },
// //       (_) {
// //         emit(PasswordAuthSuccess());
// //       },
// //     );
// //   }

// //   Future<void> register({
// //     required String phone,
// //     required String password,
// //   }) async {
// //     if (state is PasswordAuthLoading) return;

// //     emit(PasswordAuthLoading());

// //     final result = await registerUsecase(
// //       phone: phone,
// //       password: password,
// //     );

// //     if (isClosed) return;

// //     result.fold(
// //       (failure) {
// //         emit(PasswordAuthError(message: failure.message));
// //       },
// //       (_) {
// //         emit(PasswordAuthSuccess());
// //       },
// //     );
// //   }

// //   Future<void> logout() async {
// //     if (state is PasswordAuthLoading) return;

// //     emit(PasswordAuthLoading());

// //     final result = await logoutUsecase();

// //     if (isClosed) return;

// //     result.fold(
// //       (failure) {
// //         emit(PasswordAuthError(message: failure.message));
// //       },
// //       (_) {
// //         emit(PasswordAuthInitial());
// //       },
// //     );
// //   }
// // }

// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:el_nada_market/features/auth/domain/usecases/login_with_password_usecase.dart';
// import 'package:el_nada_market/features/auth/domain/usecases/register_with_password_usecase.dart';
// import 'package:el_nada_market/features/auth/domain/usecases/logout_usecase.dart';

// import 'password_auth_state.dart';

// class PasswordAuthCubit extends Cubit<PasswordAuthState> {
//   final LoginWithPasswordUsecase loginUsecase;
//   final RegisterWithPasswordUsecase registerUsecase;
//   final LogoutUsecase logoutUsecase;

//   PasswordAuthCubit({
//     required this.loginUsecase,
//     required this.registerUsecase,
//     required this.logoutUsecase,
//   }) : super(PasswordAuthInitial());

//   Future<void> login({
//     required String phone,
//     required String password,
//   }) async {
//     if (state is PasswordAuthLoading) return;

//     emit(PasswordAuthLoading());

//     final result = await loginUsecase(
//       phone: phone,
//       password: password,
//     );

//     if (isClosed) return;

//     result.fold(
//       (failure) {
//         emit(PasswordAuthError(message: failure.message));
//       },
//       (_) {
//         emit(PasswordAuthSuccess());
//       },
//     );
//   }

//   Future<void> register({
//     required String nickname,
//     required String phone,
//     required String password,
//   }) async {
//     if (state is PasswordAuthLoading) return;

//     emit(PasswordAuthLoading());

//     final result = await registerUsecase(
//       nickname: nickname,
//       phone: phone,
//       password: password,
//     );

//     if (isClosed) return;

//     result.fold(
//       (failure) {
//         emit(PasswordAuthError(message: failure.message));
//       },
//       (_) {
//         emit(PasswordAuthSuccess());
//       },
//     );
//   }

//   Future<void> logout() async {
//     if (state is PasswordAuthLoading) return;

//     emit(PasswordAuthLoading());

//     final result = await logoutUsecase();

//     if (isClosed) return;

//     result.fold(
//       (failure) {
//         emit(PasswordAuthError(message: failure.message));
//       },
//       (_) {
//         emit(PasswordAuthInitial());
//       },
//     );
//   }
// }

import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:el_nada_market/features/auth/domain/usecases/login_with_password_usecase.dart';
import 'package:el_nada_market/features/auth/domain/usecases/register_with_password_usecase.dart';
import 'package:el_nada_market/features/auth/domain/usecases/logout_usecase.dart';

import 'password_auth_state.dart';

class PasswordAuthCubit extends Cubit<PasswordAuthState> {
  final LoginWithPasswordUsecase loginUsecase;
  final RegisterWithPasswordUsecase registerUsecase;
  final LogoutUsecase logoutUsecase;

  PasswordAuthCubit({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.logoutUsecase,
  }) : super(PasswordAuthInitial());

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    if (state is PasswordAuthLoading) return;

    emit(PasswordAuthLoading());

    final result = await loginUsecase(
      phone: phone,
      password: password,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(PasswordAuthError(message: failure.message));
      },
      (user) {
        emit(PasswordAuthSuccess(user: user));
      },
    );
  }

  Future<void> register({
    required String nickname,
    required String phone,
    required String password,
  }) async {
    if (state is PasswordAuthLoading) return;

    emit(PasswordAuthLoading());

    final result = await registerUsecase(
      nickname: nickname,
      phone: phone,
      password: password,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(PasswordAuthError(message: failure.message));
      },
      (_) {
        emit(PasswordAuthSuccess());
      },
    );
  }

  Future<void> logout() async {
    if (state is PasswordAuthLoading) return;

    emit(PasswordAuthLoading());

    final result = await logoutUsecase();

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(PasswordAuthError(message: failure.message));
      },
      (_) {
        emit(PasswordAuthInitial());
      },
    );
  }
}
