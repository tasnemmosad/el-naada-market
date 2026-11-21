import 'package:dio/dio.dart';
import 'package:el_nada_market/core/network/auth_inspector.dart';
import 'package:el_nada_market/features/auth/data/data_sources/password_auth_remote_datasource.dart';
import 'package:el_nada_market/features/auth/data/repos/password_auth_repo_impl.dart';
import 'package:el_nada_market/features/auth/domain/repos/password_auth_repo.dart';
import 'package:el_nada_market/features/auth/domain/usecases/login_with_password_usecase.dart';
import 'package:el_nada_market/features/auth/domain/usecases/logout_usecase.dart';
import 'package:el_nada_market/features/auth/domain/usecases/register_with_password_usecase.dart';
import 'package:el_nada_market/features/auth/presentation/manager/password_auth_cubit.dart';
import 'package:el_nada_market/features/cart/data/data_sources/cart_remote_data_source.dart';
import 'package:el_nada_market/features/cart/manager/cart_cubit.dart';
import 'package:el_nada_market/features/orders/data/data_sources/orders_remote_data_source.dart';
import 'package:el_nada_market/features/orders/presentation/manager/orders_cubit.dart';
import 'package:el_nada_market/features/products/data/data_sources/products_remote_data_source.dart';
import 'package:el_nada_market/features/products/presentation/manager/products_cubit.dart';
import 'package:el_nada_market/features/profile/data/data_sources/profile_remote_datasource.dart';
import 'package:el_nada_market/features/profile/data/repos/profile_repo_impl.dart';
import 'package:el_nada_market/features/profile/domain/repos/profile_repo.dart';
import 'package:el_nada_market/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:el_nada_market/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:el_nada_market/features/profile/presentation/manager/profile_cubit.dart';
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
  sl.registerLazySingleton<ProfileRemoteDatasource>(
  () => ProfileRemoteDatasource(
    dio: sl<Dio>(),
  ),
);
sl.registerLazySingleton<ProductsRemoteDataSource>(
  () => ProductsRemoteDataSource(sl<Dio>()),
);
sl.registerLazySingleton<CartRemoteDataSource>(
  () => CartRemoteDataSource(sl<Dio>()),
);
sl.registerLazySingleton<OrdersRemoteDataSource>(
  () => OrdersRemoteDataSource(sl<Dio>()),
);
  //Repos
  sl.registerLazySingleton<PasswordAuthRepo>(
    () => PasswordAuthRepoImpl(
      remoteDatasource: sl<PasswordAuthRemoteDatasource>(),
    ),
  );
  sl.registerLazySingleton<ProfileRepo>(
  () => ProfileRepoImpl(
    remoteDatasource: sl<ProfileRemoteDatasource>(),
  ),
);
  //UseCases
  sl.registerLazySingleton<LoginWithPasswordUsecase>(
    () => LoginWithPasswordUsecase(repo: sl<PasswordAuthRepo>()),
  );

  sl.registerLazySingleton<RegisterWithPasswordUsecase>(
    () => RegisterWithPasswordUsecase(repo: sl<PasswordAuthRepo>()),
  );
  sl.registerLazySingleton<LogoutUsecase>(
    () => LogoutUsecase(repo: sl<PasswordAuthRepo>()),
  );
  sl.registerLazySingleton<GetProfileUsecase>(
  () => GetProfileUsecase(
    repo: sl<ProfileRepo>(),
  ),
);
sl.registerLazySingleton<UpdateProfileUsecase>(
  () => UpdateProfileUsecase(
    repo: sl<ProfileRepo>(),
  ),
);
  //Cubits
sl.registerFactory<PasswordAuthCubit>(
  () => PasswordAuthCubit(
    loginUsecase: sl<LoginWithPasswordUsecase>(),
    registerUsecase: sl<RegisterWithPasswordUsecase>(),
    logoutUsecase: sl<LogoutUsecase>(),
  ),
);
sl.registerFactory<ProfileCubit>(
  () => ProfileCubit(
    getProfileUsecase: sl<GetProfileUsecase>(),
    updateProfileUsecase: sl<UpdateProfileUsecase>(),
  ),
);
  sl.registerFactory<ProductsCubit>(
  () => ProductsCubit(sl<ProductsRemoteDataSource>()),
);
sl.registerLazySingleton<CartCubit>(
  () => CartCubit(sl<CartRemoteDataSource>()),
);
sl.registerFactory<OrdersCubit>(
  () => OrdersCubit(sl<OrdersRemoteDataSource>()),
);
}
