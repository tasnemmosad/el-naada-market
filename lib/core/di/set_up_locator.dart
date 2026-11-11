import 'package:dio/dio.dart';
import 'package:el_nada_market/core/network/auth_inspector.dart';
import 'package:el_nada_market/features/auth/data/data_sources/password_auth_remote_datasource.dart';
import 'package:el_nada_market/features/auth/data/repos/password_auth_repo_impl.dart';

import 'package:el_nada_market/features/auth/domain/repos/password_auth_repo.dart';
import 'package:el_nada_market/features/auth/domain/usecases/login_with_password_usecase.dart';
import 'package:el_nada_market/features/auth/domain/usecases/register_with_password_usecase.dart';

import 'package:el_nada_market/features/auth/presentation/manager/password_auth_cubit.dart';
import 'package:el_nada_market/features/cart/manager/cart_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:get_it/get_it.dart';
// import 'package:firebase_auth/firebase_auth.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Dio
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://192.168.1.8:3000',
        ),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(secureStorage: sl<FlutterSecureStorage>()),
    );

    return dio;
  });
  //datasources
  sl.registerLazySingleton<PasswordAuthRemoteDatasource>(
    () => PasswordAuthRemoteDatasource(dio: sl<Dio>(), secureStorage: sl()),
  );
  //Repos
  sl.registerLazySingleton<PasswordAuthRepo>(
    () => PasswordAuthRepoImpl(
      remoteDatasource: sl<PasswordAuthRemoteDatasource>(),
    ),
  );
  //UseCases
  sl.registerLazySingleton<LoginWithPasswordUsecase>(
    () => LoginWithPasswordUsecase(repo: sl<PasswordAuthRepo>()),
  );

  sl.registerLazySingleton<RegisterWithPasswordUsecase>(
    () => RegisterWithPasswordUsecase(repo: sl<PasswordAuthRepo>()),
  );
  //Cubits
  sl.registerFactory<PasswordAuthCubit>(
    () => PasswordAuthCubit(
      loginUsecase: sl<LoginWithPasswordUsecase>(),
      registerUsecase: sl<RegisterWithPasswordUsecase>(),
    ),
  );
  sl.registerLazySingleton<CartCubit>(() => CartCubit());
}
