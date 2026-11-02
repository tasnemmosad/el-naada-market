
import 'package:dartz/dartz.dart';
import 'package:el_nada_market/core/errors/failure.dart';
// import 'package:meals_app/core/errors/Failure.dart';

abstract class NoParamUseCase<T> {
 Future<Either <Failure , T > > call();

}
