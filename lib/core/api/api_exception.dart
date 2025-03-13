class ApiException implements Exception {
  final String message;
  final String prefix;

  ApiException([this.message = "", this.prefix = ""]);

  @override
  String toString() {
    return "$prefix$message";
  }
}

class FetchDataException extends ApiException {
  FetchDataException(String message)
      : super(message, "Error During Communication: ");
}

class BadRequestException extends ApiException {
  BadRequestException(String message) : super(message, "Invalid Request: ");
}

class InternalServerException extends ApiException {
  InternalServerException(String message) : super(message, "Internal Server: ");
}
