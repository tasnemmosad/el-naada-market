
// sealed class PasswordAuthState {}

// class PasswordAuthInitial extends PasswordAuthState {}

// class PasswordAuthLoading extends PasswordAuthState {}

// class PasswordAuthSuccess extends PasswordAuthState {}

// class PasswordAuthError extends PasswordAuthState {
//   final String message;

//   PasswordAuthError({
//     required this.message,
//   });
// }

import 'package:el_nada_market/features/auth/domain/entities/auth_user.dart';

sealed class PasswordAuthState {}

class PasswordAuthInitial extends PasswordAuthState {}

class PasswordAuthLoading extends PasswordAuthState {}

class PasswordAuthSuccess extends PasswordAuthState {
  final AuthUser? user;

  PasswordAuthSuccess({
    this.user,
  });
}

class PasswordAuthError extends PasswordAuthState {
  final String message;

  PasswordAuthError({
    required this.message,
  });
}
