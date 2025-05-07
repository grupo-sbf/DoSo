import 'package:doso/src/impl/do_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('states', () {
    test('Should return true for Initial state and false for others', () {
      const handler = Initial<int>();

      expect(handler.isInitial, isTrue);
      expect(handler.isLoading, isFalse);
      expect(handler.isSuccess, isFalse);
      expect(handler.isFailure, isFalse);
    });

    test('Should return true for Loading state and false for others', () {
      const handler = Loading<int>();

      expect(handler.isInitial, isFalse);
      expect(handler.isLoading, isTrue);
      expect(handler.isSuccess, isFalse);
      expect(handler.isFailure, isFalse);
    });

    test('Should return true for Success state with value and false for others',
        () {
      const handler = Success<int>(42);

      expect(handler.getOrElse(0), equals(42));
      expect(handler.isInitial, isFalse);
      expect(handler.isLoading, isFalse);
      expect(handler.isSuccess, isTrue);
      expect(handler.isFailure, isFalse);
    });

    test('Success state should handle default value if null', () {
      const handler = Success<int?>(null);

      expect(handler.getOrElse(0), 0);
      expect(handler.isInitial, isFalse);
      expect(handler.isLoading, isFalse);
      expect(handler.isSuccess, isTrue);
      expect(handler.isFailure, isFalse);
    });

    test('Failure state should return the correct exception and stackTrace',
        () {
      final exceptionThrown = Exception('Test exception');
      final stackTraceThrown = StackTrace.current;
      final handler = Failure<int>(exceptionThrown, stackTraceThrown);

      expect(handler.getOrElse(0), 0);
      expect(handler.isInitial, isFalse);
      expect(handler.isLoading, isFalse);
      expect(handler.isSuccess, isFalse);
      expect(handler.isFailure, isTrue);
      handler.fold(
        onFailure: (exception, stackTrace) {
          expect(exception, equals(exceptionThrown));
          expect(stackTrace, equals(stackTraceThrown));
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('Failure state should handle null stackTrace correctly', () {
      final exceptionThrown = Exception('Test exception');
      final handler = Failure<int>(exceptionThrown);

      expect(handler.getOrElse(0), 0);
      expect(handler.isInitial, isFalse);
      expect(handler.isLoading, isFalse);
      expect(handler.isSuccess, isFalse);
      expect(handler.isFailure, isTrue);
      handler.fold(
        onFailure: (exception, stackTrace) {
          expect(exception, equals(exceptionThrown));
          expect(stackTrace, equals(isNull));
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('Failure state should handle null exception and stackTrace', () {
      const handler = Failure<int>();

      expect(handler.getOrElse(0), 0);
      expect(handler.isInitial, isFalse);
      expect(handler.isLoading, isFalse);
      expect(handler.isSuccess, isFalse);
      expect(handler.isFailure, isTrue);
      handler.fold(
        onFailure: (exception, stackTrace) {
          expect(exception, equals(isNull));
          expect(stackTrace, equals(isNull));
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });
  });

  group('getOrElse', () {
    test(
        'getOrElse should return the value if Success or the default value otherwise',
        () async {
      const successHandler = Success<int>(42);
      const failureHandler = Failure<int>();

      expect(successHandler.getOrElse(0), equals(42));
      expect(failureHandler.getOrElse(0), equals(0));
    });

    test('getOrElse should return null when default value is null', () async {
      const handler = Failure<int?>();
      final result = handler.getOrElse(null);

      expect(result, isNull);
    });
  });

  group('map', () {
    test('map should transform the value in Success and propagate Failure', () {
      const successHandler = Success(42);
      final failureHandler = Failure<int>(Exception('Test exception'));

      final mappedSuccess = successHandler.map((value) => value.toString());
      final mappedFailure = failureHandler.map((value) => value.toString());
      expect(mappedSuccess.isSuccess, isTrue);
      expect(mappedSuccess.getOrElse('failure'), equals('42'));

      expect(mappedFailure.isFailure, isTrue);
      mappedFailure.fold(
        onFailure: (exception, stackTrace) {
          expect(exception, isNotNull);
          expect(stackTrace, isNull);
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('map should handle Success with null return value', () {
      const handler = Success<int>(42);
      final mappedHandler = handler.map((value) => null);

      expect(mappedHandler, isA<Success<void>>());
    });

    test('map should throw exception for Initial or Loading states', () {
      const initialHandler = Initial<int>();
      const loadingHandler = Loading<int>();

      expect(
        () => initialHandler.map((value) => value.toString()),
        throwsException,
      );

      expect(
        () => loadingHandler.map((value) => value.toString()),
        throwsException,
      );
    });
  });

  group('flatMap', () {
    test(
        'flatMap should transform the value in Success and return a new Do state',
        () {
      const successHandler = Success<int>(42);

      final flatMappedHandler = successHandler.flatMap(
        (value) => Success<String>('Value: $value'),
      );

      expect(flatMappedHandler.isSuccess, isTrue);
      expect(flatMappedHandler.getOrElse('failure'), equals('Value: 42'));
    });

    test('flatMap should propagate Failure without applying the mapper', () {
      final failureHandler = Failure<int>(Exception('Test exception'));

      final flatMappedHandler = failureHandler.flatMap(
        (value) => Success<String>('Value: $value'),
      );

      expect(flatMappedHandler.isFailure, isTrue);
      flatMappedHandler.fold(
        onFailure: (exception, stackTrace) {
          expect(exception, isNotNull);
          expect(stackTrace, isNull);
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('flatMap should throw an exception for Initial or Loading states', () {
      const initialHandler = Initial<int>();
      const loadingHandler = Loading<int>();

      expect(
        () =>
            initialHandler.flatMap((value) => Success<String>('Value: $value')),
        throwsException,
      );

      expect(
        () =>
            loadingHandler.flatMap((value) => Success<String>('Value: $value')),
        throwsException,
      );
    });

    test('flatMap should handle Success with a null value', () {
      const handler = Success<int?>(null);

      final flatMappedHandler = handler.flatMap(
        (value) => Success<String>('Value: $value'),
      );

      expect(flatMappedHandler.isSuccess, isTrue);
      expect(flatMappedHandler.getOrElse('failure'), equals('Value: null'));
    });

    test('flatMap should propagate Failure with a stackTrace', () {
      final exceptionThrown = Exception('Test exception');
      final stackTraceThrown = StackTrace.current;
      final failureHandler = Failure<int>(exceptionThrown, stackTraceThrown);

      final flatMappedHandler = failureHandler.flatMap(
        (value) => Success<String>('Value: $value'),
      );

      expect(flatMappedHandler.isFailure, isTrue);
      flatMappedHandler.fold(
        onFailure: (exception, stackTrace) {
          expect(exception, equals(exceptionThrown));
          expect(stackTrace, equals(stackTraceThrown));
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('flatMap should handle Success with a mapper returning Failure', () {
      const successHandler = Success<int>(42);

      final flatMappedHandler = successHandler.flatMap(
        (value) => Failure<String>(Exception('Mapped failure')),
      );

      expect(flatMappedHandler.isFailure, isTrue);
      flatMappedHandler.fold(
        onFailure: (exception, stackTrace) {
          expect(exception, isA<Exception>());
          expect(exception.toString(), contains('Mapped failure'));
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('flatMap should handle Success with a mapper returning Initial', () {
      const successHandler = Success<int>(42);

      final flatMappedHandler = successHandler.flatMap(
        (value) => const Initial<String>(),
      );

      expect(flatMappedHandler, isA<Initial<String>>());
    });

    test('flatMap should handle Success with a mapper returning Loading', () {
      const successHandler = Success<int>(42);

      final flatMappedHandler = successHandler.flatMap(
        (value) => const Loading<String>(),
      );

      expect(flatMappedHandler, isA<Loading<String>>());
    });
  });

  group('fold', () {
    test('fold should execute the correct callback based on the state', () {
      const successHandler = Success<int>(42);
      final failureHandler = Failure<int>(Exception('Test exception'));

      final successResult = successHandler.fold(
        onFailure: (exception, _) => 'Failure: $exception',
        onSuccess: (value) => 'Success: $value',
      );
      final failureResult = failureHandler.fold(
        onFailure: (exception, _) => 'Failure: $exception',
        onSuccess: (value) => 'Success',
      );

      expect(successResult, equals('Success: 42'));
      expect(failureResult, startsWith('Failure: Exception: Test exception'));
    });

    test('fold should transform Success value to a different type', () {
      const handler = Success<int>(42);

      final result = handler.fold(
        onFailure: (exception, _) => 'Failure',
        onSuccess: (value) => 'Value: $value',
      );

      expect(result, equals('Value: 42'));
    });

    test('fold should throw exception for Initial or Loading states', () {
      const initialHandler = Initial<int>();
      const loadingHandler = Loading<int>();

      expect(
        () => initialHandler.fold(
          onFailure: (exception, _) => 'Failure',
          onSuccess: (value) => 'Success',
        ),
        throwsException,
      );

      expect(
        () => loadingHandler.fold(
          onFailure: (exception, _) => 'Failure',
          onSuccess: (value) => 'Success',
        ),
        throwsException,
      );
    });
  });

  group('when', () {
    test('when should execute the correct callback based on the state', () {
      const initialHandler = Initial<int>();
      const loadingHandler = Loading<int>();
      const successHandler = Success<int>(42);
      final failureHandler = Failure<int>(Exception('Test exception'));

      final initialResult = initialHandler.when(
        onInitial: () => 'Initial',
        onLoading: () => 'Loading',
        onSuccess: (value) => 'Success: $value',
        onFailure: (exception, _) => 'Failure',
      );
      final loadingResult = loadingHandler.when(
        onInitial: () => 'Initial',
        onLoading: () => 'Loading',
        onSuccess: (value) => 'Success: $value',
        onFailure: (exception, _) => 'Failure',
      );
      final successResult = successHandler.when(
        onInitial: () => 'Initial',
        onLoading: () => 'Loading',
        onSuccess: (value) => 'Success: $value',
        onFailure: (exception, _) => 'Failure',
      );
      final failureResult = failureHandler.when(
        onInitial: () => 'Initial',
        onLoading: () => 'Loading',
        onSuccess: (value) => 'Success: $value',
        onFailure: (exception, _) => 'Failure: $exception',
      );

      expect(initialResult, equals('Initial'));
      expect(loadingResult, equals('Loading'));
      expect(successResult, equals('Success: 42'));
      expect(failureResult, startsWith('Failure: Exception: Test exception'));
    });

    test('when should execute the correct callback for all states', () {
      const initialHandler = Initial<int>();
      const loadingHandler = Loading<int>();
      const successHandler = Success<int>(42);
      final failureHandler = Failure<int>(Exception('Test exception'));

      expect(
        initialHandler.when(
          onInitial: () => 'Initial',
          onLoading: () => 'Loading',
          onSuccess: (value) => 'Success: $value',
          onFailure: (exception, _) => 'Failure',
        ),
        equals('Initial'),
      );

      expect(
        loadingHandler.when(
          onInitial: () => 'Initial',
          onLoading: () => 'Loading',
          onSuccess: (value) => 'Success: $value',
          onFailure: (exception, _) => 'Failure',
        ),
        equals('Loading'),
      );

      expect(
        successHandler.when(
          onInitial: () => 'Initial',
          onLoading: () => 'Loading',
          onSuccess: (value) => 'Success: $value',
          onFailure: (exception, _) => 'Failure',
        ),
        equals('Success: 42'),
      );

      expect(
        failureHandler.when(
          onInitial: () => 'Initial',
          onLoading: () => 'Loading',
          onSuccess: (value) => 'Success: $value',
          onFailure: (exception, _) => 'Failure: $exception',
        ),
        startsWith('Failure: Exception: Test exception'),
      );
    });
  });
}
