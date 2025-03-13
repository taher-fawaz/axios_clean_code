import 'package:axios/core/api/api_exception.dart';
import 'package:axios/core/errors/exceptions.dart';
import 'package:axios/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

class APIHelperFunctions {
  // singleton object
  static final APIHelperFunctions _instance = APIHelperFunctions._internal();

  factory APIHelperFunctions() => _instance;

  APIHelperFunctions._internal();

  static Future<Either<Failure, T>> requestHandler<T>(
      Future<T> Function() function) async {
    try {
      final result = await function();
      return Right(result);
    } on BadRequestException {
      return Left(ServerFailure(message: "error"));
    } on ServerException {
      return Left(ServerFailure(message: "error"));
    } catch (e) {
      return Left(ServerFailure(message: "error"));
    }
  }
}
