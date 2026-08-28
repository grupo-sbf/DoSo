import 'package:doso/src/do.dart';
import 'package:doso/src/impl/do_exception.dart';
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

    test('Should hand the thrown object to onCatch untouched', () async {
      final result = await Do.tryCatch<Object, int>(
        onTry: () async => throw 'Generic error',
        onCatch: (error, _) => error,
      );

      expect(result.isFailure, isTrue);
      result.fold(
        onFailure: (failure) => expect(failure, equals('Generic error')),
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('Should hand an Error to onCatch with its type intact', () async {
      final result = await Do.tryCatch<Object, int>(
        onTry: () async => throw StateError('Broken invariant'),
        onCatch: (error, _) => error,
      );

      expect(result.isFailure, isTrue);
      result.fold(
        onFailure: (failure) {
          expect(failure, isA<StateError>());
          expect((failure as StateError).message, equals('Broken invariant'));
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('Should let onCatch normalize a thrown object into an Exception',
        () async {
      final result = await Do.tryCatch<Exception, int>(
        onTry: () async => throw 'Generic error',
        onCatch: (error, _) =>
            error is Exception ? error : Exception(error.toString()),
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

    test('Should preserve the original exception type when onCatch is null',
        () async {
      final result = await Do.tryCatch<Exception, int>(
        onTry: () async => throw const FormatException('Bad payload'),
      );

      expect(result.isFailure, isTrue);
      result.fold(
        onFailure: (failure) {
          expect(failure, isA<FormatException>());
          expect(failure.toString(), contains('Bad payload'));
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('Should wrap a non-Exception error when onCatch is null', () async {
      final result = await Do.tryCatch<Exception, int>(
        onTry: () async => throw StateError('Broken invariant'),
      );

      expect(result.isFailure, isTrue);
      result.fold(
        onFailure: (failure) {
          expect(failure, isA<Exception>());
          expect(failure.toString(), contains('Broken invariant'));
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test(
        'Should throw DoException when the failure type cannot hold the '
        'exception and onCatch is null', () async {
      await expectLater(
        Do.tryCatch<int, String>(
          onTry: () async => throw Exception('Test error'),
        ),
        throwsA(
          isA<DoException>().having(
            (e) => e.type,
            'type',
            DoExceptionType.unsupportedFailureType,
          ),
        ),
      );
    });

    test('Should convert to a custom failure type through onCatch', () async {
      final result = await Do.tryCatch<int, String>(
        onTry: () async => throw Exception('Test error'),
        onCatch: (_, __) => 42,
      );

      expect(result.isFailure, isTrue);
      result.fold(
        onFailure: (failure) => expect(failure, equals(42)),
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('Should run onFinally even when the failure type is unsupported',
        () async {
      var finallyExecuted = false;

      await expectLater(
        Do.tryCatch<int, String>(
          onTry: () async => throw Exception('Test error'),
          onFinally: () => finallyExecuted = true,
        ),
        throwsA(isA<DoException>()),
      );

      expect(finallyExecuted, isTrue);
    });
  });
}
