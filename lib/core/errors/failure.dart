
import 'package:dio/dio.dart';

abstract class Failure {
  final String message;

  Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  ServerFailure(super.message);

  factory ServerFailure.fromDioError(DioException e) {
    return ServerFailure(
      e.message ?? 'Unknown Dio error',
    );
  }
  
}
class AuthFailure extends Failure {
  AuthFailure(super.message);
}