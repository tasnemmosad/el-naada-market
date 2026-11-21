
import 'package:el_nada_market/features/profile/domain/entities/customer_profile.dart';

sealed class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final CustomerProfile? profile;

  ProfileLoaded({
    required this.profile,
  });
}

class ProfileUpdating extends ProfileState {
  final CustomerProfile? profile;

  ProfileUpdating({
    required this.profile,
  });
}

class ProfileUpdateSuccess extends ProfileState {
  final CustomerProfile profile;

  ProfileUpdateSuccess({
    required this.profile,
  });
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({
    required this.message,
  });
}
