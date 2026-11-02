
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:el_nada_market/features/auth/domain/usecases/login_with_password_usecase.dart';
import 'package:el_nada_market/features/auth/domain/usecases/register_with_password_usecase.dart';

import 'password_auth_state.dart';

class PasswordAuthCubit extends Cubit<PasswordAuthState> {
  final LoginWithPasswordUsecase loginUsecase;
  final RegisterWithPasswordUsecase registerUsecase;

  PasswordAuthCubit({
    required this.loginUsecase,
    required this.registerUsecase,
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
        emit(
          PasswordAuthError(message: failure.message),
        );
      },
      (_) {
        emit(PasswordAuthSuccess());
      },
    );
  }

  Future<void> register({
    required String phone,
    required String password,
  }) async {
    if (state is PasswordAuthLoading) return;

    emit(PasswordAuthLoading());

    final result = await registerUsecase(
      phone: phone,
      password: password,
    );

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(
          PasswordAuthError(message: failure.message),
        );
      },
      (_) {
        emit(PasswordAuthSuccess());
      },
    );
  }
}
