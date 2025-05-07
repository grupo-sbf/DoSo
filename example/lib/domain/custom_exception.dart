class CustomException implements Exception {
  const CustomException(
    this.message, {
    this.exception,
    this.stackTrace,
  });

  final String message;
  final Exception? exception;
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}
