import 'dart:async';

import 'do.dart';

/// A type alias for [FutureOr<Do<S>>].
///
/// This is used to represent a result that can be either a [Do] object or a
/// [Future] that resolves to a [Do] object.
/// /// It is useful for functions that can return a [Do] object directly or
/// asynchronously.
///
/// Example usage:
/// ```dart
/// So<MyData> fetchData() => Do.tryCatch(
///     onTry: () async {
///       final response = await http.get('https://api.example.com/data');
///       return response.data;
///     },
/// ```
typedef So<S> = FutureOr<Do<S>>;
