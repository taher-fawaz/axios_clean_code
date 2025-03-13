import '../errors/failures.dart';

String mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return "Server Failure";

    default:
      return "Unexpected error";
  }
}
