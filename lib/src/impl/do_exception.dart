enum DoExceptionType {
  invalidState,
}

class DoException implements Exception {
  const DoException({
    required this.type,
    required this.message,
  });

  final DoExceptionType type;
  final String message;

  @override
  String toString() => 'DoException: {$type, $message}';
}
