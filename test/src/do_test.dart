import 'package:doso/src/do.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tryCatch', () {
    test('Should return Do.success when onTry succeeds', () async {
      final result = await Do.tryCatch(
        onTry: () async => 42,
      );

      expect(result.isSuccess, isTrue);
      expect(result.getOrElse(0), equals(42));
    });

    test('Should return Do.failure when onTry throws an exception', () async {
      final result = await Do.tryCatch(
        onTry: () async => throw Exception('Test error'),
      );

      expect(result.isFailure, isTrue);
      result.fold(
        onFailure: (failure) {
          expect(failure, isA<Exception>());
          expect(failure.toString(), contains('Test error'));
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('Should use onCatch to handle custom exceptions', () async {
      final result = await Do.tryCatch(
        onTry: () async => throw Exception('Test error'),
        onCatch: (_, __) => Exception('Handled error'),
      );

      expect(result.isFailure, isTrue);
      result.fold(
        onFailure: (failure) {
          expect(failure.toString(), contains('Handled error'));
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('Should handle generic errors when onCatch is not provided', () async {
      final result = await Do.tryCatch(
        onTry: () async => throw 'Generic error',
      );

      expect(result.isFailure, isTrue);
      result.fold(
        onFailure: (failure) => expect(failure, contains('Generic error')),
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('Should handle generic errors when onCatch is provided', () async {
      final result = await Do.tryCatch(
        onTry: () async => throw 'Generic error',
        onCatch: (exception, _) => exception,
      );

      expect(result.isFailure, isTrue);
      result.fold(
        onFailure: (failure) {
          expect(failure, isA<Exception>());
          expect(failure.toString(), contains('Generic error'));
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('Should execute onFinally after onTry', () async {
      var finallyExecuted = false;

      await Do.tryCatch(
        onTry: () async => throw Exception('Test error'),
        onFinally: () {
          finallyExecuted = true;
        },
      );

      expect(finallyExecuted, isTrue);
    });
  });
}
