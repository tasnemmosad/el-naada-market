
sealed class PasswordAuthState {}

class PasswordAuthInitial extends PasswordAuthState {}

class PasswordAuthLoading extends PasswordAuthState {}

class PasswordAuthSuccess extends PasswordAuthState {}

class PasswordAuthError extends PasswordAuthState {
  final String message;

  PasswordAuthError({
    required this.message,
  });
}
