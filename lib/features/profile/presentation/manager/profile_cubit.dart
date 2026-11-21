
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:el_nada_market/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:el_nada_market/features/profile/domain/usecases/update_profile_usecase.dart';

import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUsecase getProfileUsecase;
  final UpdateProfileUsecase updateProfileUsecase;

  ProfileCubit({
    required this.getProfileUsecase,
    required this.updateProfileUsecase,
  }) : super(ProfileInitial());

  Future<void> getProfile() async {
    if (state is ProfileLoading) return;

    emit(ProfileLoading());

    final result = await getProfileUsecase();

    if (isClosed) return;

    result.fold(
      (failure) {
        emit(ProfileError(message: failure.message));
      },
      (profile) {
        emit(ProfileLoaded(profile: profile));
      },
    );
  }

  Future<void> updateProfile({
    required String name,
    required String address,
    String? phone2,
    required String paymentMethod,
  }) async {
    if (state is ProfileUpdating) return;

    final currentProfile = state is ProfileLoaded
        ? (state as ProfileLoaded).profile
        : null;

    emit(ProfileUpdating(profile: currentProfile));

    final result = await updateProfileUsecase(
      name: name,
      address: address,
      phone2: phone2,
      paymentMethod: paymentMethod,
    );

    if (isClosed) return;

    await result.fold(
      (failure) async {
        emit(ProfileError(message: failure.message));
      },
      (_) async {
        // Fetch saved data again from backend
        final refreshed = await getProfileUsecase();

        if (isClosed) return;

        refreshed.fold(
          (failure) {
            emit(ProfileError(message: failure.message));
          },
          (profile) {
            if (profile == null) {
              emit(
                ProfileError(
                  message: 'تم الحفظ ولكن تعذر تحميل بيانات العميل.',
                ),
              );
              return;
            }

            emit(ProfileUpdateSuccess(profile: profile));
          },
        );
      },
    );
  }
}
