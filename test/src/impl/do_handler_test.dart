import 'package:doso/src/impl/do_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('states', () {
    test('Should return true for Initial state and false for others', () {
      const handler = Initial<Exception, int>();

      expect(handler.isInitial, isTrue);
      expect(handler.isLoading, isFalse);
      expect(handler.isSuccess, isFalse);
      expect(handler.isFailure, isFalse);
    });

    test('Should return true for Loading state and false for others', () {
      const handler = Loading<Exception, int>();

      expect(handler.isInitial, isFalse);
      expect(handler.isLoading, isTrue);
      expect(handler.isSuccess, isFalse);
      expect(handler.isFailure, isFalse);
    });

    test('Should return true for Success state with value and false for others',
        () {
      const handler = Success<Exception, int>(42);

      expect(handler.getOrElse(0), equals(42));
      expect(handler.isInitial, isFalse);
      expect(handler.isLoading, isFalse);
      expect(handler.isSuccess, isTrue);
      expect(handler.isFailure, isFalse);
    });

    test('Success state should handle default value if null', () {
      const handler = Success<Exception, int?>(null);

      expect(handler.getOrElse(0), 0);
      expect(handler.isInitial, isFalse);
      expect(handler.isLoading, isFalse);
      expect(handler.isSuccess, isTrue);
      expect(handler.isFailure, isFalse);
    });

    test('Failure state should return the correct exception and stackTrace',
        () {
      final exceptionThrown = Exception('Test exception');
      final handler = Failure<Exception, int>(exceptionThrown);

      expect(handler.getOrElse(0), 0);
      expect(handler.isInitial, isFalse);
      expect(handler.isLoading, isFalse);
      expect(handler.isSuccess, isFalse);
      expect(handler.isFailure, isTrue);
      handler.fold(
        onFailure: (failure) => expect(failure, equals(exceptionThrown)),
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('Failure state should handle null exception and stackTrace', () {
      const handler = Failure<Exception?, int>();

      expect(handler.getOrElse(0), 0);
      expect(handler.isInitial, isFalse);
      expect(handler.isLoading, isFalse);
      expect(handler.isSuccess, isFalse);
      expect(handler.isFailure, isTrue);
      handler.fold(
        onFailure: (failure) => expect(failure, isNull),
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });
  });

  group('getOrElse', () {
    test(
        'getOrElse should return the value if Success or the default value otherwise',
        () async {
      const successHandler = Success<Exception, int>(42);
      const failureHandler = Failure<Exception, int>();

      expect(successHandler.getOrElse(0), equals(42));
      expect(failureHandler.getOrElse(0), equals(0));
    });

    test('getOrElse should return null when default value is null', () async {
      const handler = Failure<Exception, int?>();
      final result = handler.getOrElse(null);

      expect(result, isNull);
    });
  });

  group('map', () {
    test('map should transform the value in Success and propagate Failure', () {
      const successHandler = Success(42);
      final failureHandler = Failure<Exception, int>(
        Exception('Test exception'),
      );

      final mappedSuccess = successHandler.map((value) => value.toString());
      final mappedFailure = failureHandler.map((value) => value.toString());
      expect(mappedSuccess.isSuccess, isTrue);
      expect(mappedSuccess.getOrElse('failure'), equals('42'));

      expect(mappedFailure.isFailure, isTrue);
      mappedFailure.fold(
        onFailure: (failure) => expect(failure, isNotNull),
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('map should handle Success with null return value', () {
      const handler = Success<Exception, int>(42);
      final mappedHandler = handler.map((value) => null);

      expect(mappedHandler, isA<Success<Exception, void>>());
    });

    test('map should throw exception for Initial or Loading states', () {
      const initialHandler = Initial<Exception, int>();
      const loadingHandler = Loading<Exception, int>();

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
      const successHandler = Success<Exception, int>(42);

      final flatMappedHandler = successHandler.flatMap(
        (value) => Success<Exception, String>('Value: $value'),
      );

      expect(flatMappedHandler.isSuccess, isTrue);
      expect(flatMappedHandler.getOrElse('failure'), equals('Value: 42'));
    });

    test('flatMap should propagate Failure without applying the mapper', () {
      final failureHandler = Failure<Exception, int>(
        Exception('Test exception'),
      );

      final flatMappedHandler = failureHandler.flatMap(
        (value) => Success<Exception, String>('Value: $value'),
      );

      expect(flatMappedHandler.isFailure, isTrue);
      flatMappedHandler.fold(
        onFailure: (failure) => expect(failure, isNotNull),
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('flatMap should throw an exception for Initial or Loading states', () {
      const initialHandler = Initial<Exception, int>();
      const loadingHandler = Loading<Exception, int>();

      expect(
        () => initialHandler.flatMap(
          (value) => Success<Exception, String>('Value: $value'),
        ),
        throwsException,
      );

      expect(
        () => loadingHandler.flatMap(
          (value) => Success<Exception, String>('Value: $value'),
        ),
        throwsException,
      );
    });

    test('flatMap should handle Success with a null value', () {
      const handler = Success<Exception, int?>(null);

      final flatMappedHandler = handler.flatMap(
        (value) => Success<Exception, String>('Value: $value'),
      );

      expect(flatMappedHandler.isSuccess, isTrue);
      expect(flatMappedHandler.getOrElse('failure'), equals('Value: null'));
    });

    test('flatMap should propagate Failure', () {
      final exceptionThrown = Exception('Test exception');
      final failureHandler = Failure<Exception, int>(exceptionThrown);

      final flatMappedHandler = failureHandler.flatMap(
        (value) => Success<Exception, String>('Value: $value'),
      );

      expect(flatMappedHandler.isFailure, isTrue);
      flatMappedHandler.fold(
        onFailure: (failure) => expect(failure, equals(exceptionThrown)),
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('flatMap should handle Success with a mapper returning Failure', () {
      const successHandler = Success<Exception, int>(42);

      final flatMappedHandler = successHandler.flatMap(
        (value) => Failure<Exception, String>(Exception('Mapped failure')),
      );

      expect(flatMappedHandler.isFailure, isTrue);
      flatMappedHandler.fold(
        onFailure: (failure) {
          expect(failure, isA<Exception>());
          expect(failure.toString(), contains('Mapped failure'));
        },
        onSuccess: (_) => fail('Expected failure, but got success'),
      );
    });

    test('flatMap should handle Success with a mapper returning Initial', () {
      const successHandler = Success<Exception, int>(42);

      final flatMappedHandler = successHandler.flatMap(
        (value) => const Initial<Exception, String>(),
      );

      expect(flatMappedHandler, isA<Initial<Exception, String>>());
    });

    test('flatMap should handle Success with a mapper returning Loading', () {
      const successHandler = Success<Exception, int>(42);

      final flatMappedHandler = successHandler.flatMap(
        (value) => const Loading<Exception, String>(),
      );

      expect(flatMappedHandler, isA<Loading<Exception, String>>());
    });
  });

  group('fold', () {
    test('fold should execute the correct callback based on the state', () {
      const successHandler = Success<Exception, int>(42);
      final failureHandler = Failure<Exception, int>(
        Exception('Test exception'),
      );

      final successResult = successHandler.fold(
        onFailure: (failure) => 'Failure: $failure',
        onSuccess: (value) => 'Success: $value',
      );
      final failureResult = failureHandler.fold(
        onFailure: (failure) => 'Failure: $failure',
        onSuccess: (value) => 'Success',
      );

      expect(successResult, equals('Success: 42'));
      expect(failureResult, startsWith('Failure: Exception: Test exception'));
    });

    test('fold should transform Success value to a different type', () {
      const handler = Success<Exception, int>(42);

      final result = handler.fold(
        onFailure: (failure) => 'Failure',
        onSuccess: (value) => 'Value: $value',
      );

      expect(result, equals('Value: 42'));
    });

    test('fold should throw exception for Initial or Loading states', () {
      const initialHandler = Initial<Exception, int>();
      const loadingHandler = Loading<Exception, int>();

      expect(
        () => initialHandler.fold(
          onFailure: (failure) => 'Failure',
          onSuccess: (value) => 'Success',
        ),
        throwsException,
      );

      expect(
        () => loadingHandler.fold(
          onFailure: (failure) => 'Failure',
          onSuccess: (value) => 'Success',
        ),
        throwsException,
      );
    });
  });

  group('when', () {
    test('when should execute the correct callback based on the state', () {
      const initialHandler = Initial<Exception, int>();
      const loadingHandler = Loading<Exception, int>();
      const successHandler = Success<Exception, int>(42);
      final failureHandler = Failure<Exception, int>(
        Exception('Test exception'),
      );

      final initialResult = initialHandler.when(
        onInitial: () => 'Initial',
        onLoading: () => 'Loading',
        onSuccess: (value) => 'Success: $value',
        onFailure: (failure) => 'Failure',
      );
      final loadingResult = loadingHandler.when(
        onInitial: () => 'Initial',
        onLoading: () => 'Loading',
        onSuccess: (value) => 'Success: $value',
        onFailure: (failure) => 'Failure',
      );
      final successResult = successHandler.when(
        onInitial: () => 'Initial',
        onLoading: () => 'Loading',
        onSuccess: (value) => 'Success: $value',
        onFailure: (failure) => 'Failure',
      );
      final failureResult = failureHandler.when(
        onInitial: () => 'Initial',
        onLoading: () => 'Loading',
        onSuccess: (value) => 'Success: $value',
        onFailure: (failure) => 'Failure: $failure',
      );

      expect(initialResult, equals('Initial'));
      expect(loadingResult, equals('Loading'));
      expect(successResult, equals('Success: 42'));
      expect(failureResult, startsWith('Failure: Exception: Test exception'));
    });

    test('when should execute the correct callback for all states', () {
      const initialHandler = Initial<Exception, int>();
      const loadingHandler = Loading<Exception, int>();
      const successHandler = Success<Exception, int>(42);
      final failureHandler = Failure<Exception, int>(
        Exception('Test exception'),
      );

      expect(
        initialHandler.when(
          onInitial: () => 'Initial',
          onLoading: () => 'Loading',
          onSuccess: (value) => 'Success: $value',
          onFailure: (failure) => 'Failure',
        ),
        equals('Initial'),
      );

      expect(
        loadingHandler.when(
          onInitial: () => 'Initial',
          onLoading: () => 'Loading',
          onSuccess: (value) => 'Success: $value',
          onFailure: (failure) => 'Failure',
        ),
        equals('Loading'),
      );

      expect(
        successHandler.when(
          onInitial: () => 'Initial',
          onLoading: () => 'Loading',
          onSuccess: (value) => 'Success: $value',
          onFailure: (failure) => 'Failure',
        ),
        equals('Success: 42'),
      );

      expect(
        failureHandler.when(
          onInitial: () => 'Initial',
          onLoading: () => 'Loading',
          onSuccess: (value) => 'Success: $value',
          onFailure: (failure) => 'Failure: $failure',
        ),
        startsWith('Failure: Exception: Test exception'),
      );
    });
  });
}
