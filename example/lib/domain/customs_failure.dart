enum NetworkFailureType {
  unexpected(1, 'Ops! Unexpected error occurred'),
  notFound(2, 'Ops! Not found the resource'),
  internalServer(3, 'Ops! Internal server error occurred');

  const NetworkFailureType(this.code, this.message);

  final int code;
  final String message;
}

interface class NetworkFailure {
  NetworkFailureType get type => NetworkFailureType.unexpected;

  String get message => type.message;

  @override
  String toString() => message;
}

class UnexpectedFailure extends NetworkFailure {
  @override
  NetworkFailureType get type => NetworkFailureType.unexpected;
}

class NotFoundFailure extends NetworkFailure {
  @override
  NetworkFailureType get type => NetworkFailureType.notFound;
}

class InternalServerErrorFailure extends NetworkFailure {
  @override
  NetworkFailureType get type => NetworkFailureType.internalServer;
}
