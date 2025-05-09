import 'dart:async';

import 'do.dart';

/// A type alias for a function that returns a `FutureOr` of type `Do<S, F>`.
///
/// This is used to represent a computation that may succeed or fail.
/// The type parameters [S] and [F] represent the success and failure types,
/// respectively.
///
/// This type alias is useful for defining functions that perform asynchronous
/// operations and return a result wrapped in a [Do] object.
/// The [So] type alias is a shorthand for `FutureOr<Do<S, F>>`, which means
/// that the function can return either a `Future` or a synchronous
/// `Do` object.
///
/// The [So] type alias is commonly used in the context of functional
/// programming and error handling, where you want to represent a
/// computation that can either succeed with a value of type [S] or fail
/// with an error of type [F].
///
/// This allows you to handle success and failure cases in a consistent
/// and type-safe manner.
/// For example, you might use [So] to represent a network request that can
/// either return a successful response or an error.
///
/// ```dart
/// So<String, Exception> fetchData() async {
///  return Do.tryCatch(
///    onTry: () async {
///     final response = await http.get('https://api.example.com/data');
///     return response.data;
///    },
///    onCatch: (exception, stackTrace) {
///     // Handle the exception and return a custom error
///     return Exception('Failed to fetch data');
///    },
///    onFinally: () {
///     // Perform any cleanup or finalization
///    },
///  );
/// }
/// ```
typedef So<F, S> = FutureOr<Do<F, S>>;

/// A type alias for a function that returns a `FutureOr` of type `Do<S, Exception>`.
///
/// This is used to represent a computation that may succeed or fail with an
/// exception.
///
/// The type parameter [S] represents the success type.
typedef SoException<S> = FutureOr<Do<Exception, S>>;
