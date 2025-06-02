import 'dart:async';

import 'impl/do_handler.dart';
import 'so.dart';

abstract interface class Do<F, S> {
  const factory Do.initial() = Initial<F, S>;

  const factory Do.loading() = Loading<F, S>;

  const factory Do.success(S value) = Success<F, S>;

  const factory Do.failure([F failure]) = Failure<F, S>;

  bool get isInitial;

  bool get isLoading;

  bool get isSuccess;

  bool get isFailure;

  /// Returns the value contained in the [Do] object if it is a success,
  /// otherwise returns the provided [defaultValue].
  ///
  /// This method allows you to handle the case where the [Do] object is
  /// not a success and provides a fallback value.
  ///
  /// Example usage:
  /// ```dart
  /// final result = Do.success(42);
  /// final value = result.getOrElse(0);
  /// print(value); // Output: 42
  /// ```
  S getOrElse(S defaultValue);

  /// Maps the [Do] object to another type [T] using the provided [mapper]
  /// function.
  ///
  /// This method allows you to transform the value contained in the
  /// [Do] object into a different type [T].
  ///
  /// Example usage:
  /// ```dart
  /// final result = Do.success(42);
  /// final mappedResult = result.map((value) => value.toString());
  /// print(mappedResult); // Output: Do<String>.success('42')
  /// ```
  So<F, T> map<T>(T Function(S value) mapper);

  /// Maps the [Do] object to another type [T] using the provided [mapper]
  /// function.
  ///
  /// This method allows you to transform the value contained in the
  /// [Do] object into a different type [T].
  ///
  /// Example usage:
  /// ```dart
  /// final result = Do.success(42);
  /// final mappedResult = result.flatMap(
  ///   (value) => Do.success(value.toString()),
  /// );
  /// print(mappedResult); // Output: Do<String>.success('42')
  /// ```
  So<F, T> flatMap<T>(Do<F, T> Function(S value) mapper);

  /// Folds the [Do] object into a single value based on its state.
  ///
  /// This method takes two functions as parameters:
  /// - [onFailure]: A function to handle the failure state, which takes an
  /// value of type [F] as a parameter.
  /// - [onSuccess]: A function to handle the success state, which takes a
  /// value of type [S] as a parameter.
  ///
  /// The [fold] method returns a value of type [T], which is determined by
  /// the provided functions.
  ///
  /// Example usage:
  /// ```dart
  /// final message = result.fold(
  ///   onFailure: (failure) => 'Failure: failure',
  ///   onSuccess: (success) => 'Success: $success',
  /// );
  T fold<T>({
    required T Function(F failure) onFailure,
    required T Function(S value) onSuccess,
  });

  /// Returns a value based on the current state of the [Do] object.
  ///
  /// This method allows you to handle different states of the [Do] object
  /// using a functional approach.
  ///
  /// The [when] method takes four functions as parameters:
  /// - [onInitial]: A function to handle the initial state.
  /// - [onLoading]: A function to handle the loading state.
  /// - [onSuccess]: A function to handle the success state, which takes a
  ///   value of type [S] as a parameter.
  /// - [onFailure]: A function to handle the failure state, which takes an
  ///   value of type [F] as a parameter.
  ///
  /// The [when] method returns a value of type [T], which is determined by
  /// the provided functions.
  ///
  /// Example usage:
  /// ```dart
  /// So<SomeType> result() {
  ///   emit(const Do.loading());
  ///
  ///   // Simulate some async operation
  ///   final result = await repository.getData();
  ///   return result.fold(
  ///     onFailure: (failure) => const Do.failure(failure),
  ///     onSuccess: (data) => const Do.success(data),
  ///   );
  /// }
  ///
  /// final message = result().when(
  ///   onInitial: () => 'Initial state',
  ///   onLoading: () => 'Loading...',
  ///   onSuccess: (value) => 'Success: $value',
  ///   onFailure: (failure) => 'Failure: failure',
  /// );
  T when<T>({
    T Function()? onInitial,
    required T Function() onLoading,
    required T Function(S value) onSuccess,
    required T Function(F failure) onFailure,
  });

  /// Same as [when] but with all states being optional and returning a 
  /// value of type [T].
  /// - [orElse]: is required to handle the case when no state matches.
  T maybeWhen<T>({
    T Function()? onInitial,
    T Function()? onLoading,
    T Function(S value)? onSuccess,
    T Function(F failure)? onFailure,
    required T Function() orElse,
  });

  /// Same as [when] but with all states being optional.
  T? whenOrNull<T>({
    T Function()? onInitial,
    T Function()? onLoading,
    T Function(S value)? onSuccess,
    T Function(F failure)? onFailure,
  });

  /// Executes the [onTry] function and returns a [So] if is a [Do] object.
  ///
  /// If the [onTry] function completes successfully, it returns a [Success]
  /// object with the result.
  /// If the [onTry] function throws an exception, it returns a [Failure]
  /// object.
  ///
  /// The [onCatch] function can be used to handle the exception and return a
  /// custom exception.
  ///
  /// The [onFinally] function is called after the [onTry] function
  /// completes, regardless of whether it was successful or not.
  ///
  /// This method is useful for wrapping operations in a
  /// [Do] object, allowing for better error handling and
  /// result management.
  ///
  /// Example usage:
  /// ```dart
  /// final result = await Do.tryCatch(
  ///   onTry: () async {
  ///     // Perform some operation
  ///     return await someAsyncOrSyncFunction();
  ///   },
  ///   onCatch: (exception, stackTrace) {
  ///     // Handle the exception and return a custom exception
  ///     return CustomException('An error occurred: $exception');
  ///   },
  ///   onFinally: () {
  ///     // Perform any cleanup or finalization
  ///   },
  ///  );
  /// ```
  static So<F, S> tryCatch<F, S>({
    required FutureOr<S> Function() onTry,
    F Function(Exception exception, StackTrace stackTrace)? onCatch,
    void Function()? onFinally,
  }) async {
    try {
      final result = await onTry();
      return Do.success(result);
    } on Exception catch (e, s) {
      if (onCatch == null) {
        return Do.failure(e as F);
      }

      return Do.failure(onCatch(e, s));
    } catch (e, s) {
      if (onCatch == null) {
        return Do.failure(e as F);
      }

      return Do.failure(onCatch(Exception(e.toString()), s));
    } finally {
      onFinally?.call();
    }
  }
}
