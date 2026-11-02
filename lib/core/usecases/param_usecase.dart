
import 'package:dartz/dartz.dart';
import 'package:el_nada_market/core/errors/failure.dart';
// import 'package:meals_app/core/errors/Failure.dart';
abstract class PramUseCase<T,Param> {
 Future<Either <Failure , T > > call(Param param);
}