## 2.0.0

**Breaking changes.**

* `Do.failure` now requires its failure value. `Do.failure()` built a `Failure`
  holding `null`, which `fold`, `when` and `maybeWhen` reached through
  `_failure as F` and threw at runtime. For a failure with no detail, type it as
  `Do<Exception?, T>` and pass `null`.
* `onCatch` in `tryCatch` receives an `Object` instead of an `Exception`.
  Callbacks with inferred parameter types are unaffected.
* `tryCatch` no longer casts its default failure to `F`. The caught error is
  kept when `F` accepts it, wrapped in an `Exception` when that fits, and a
  `DoException` with the new `DoExceptionType.unsupportedFailureType` is thrown
  otherwise.
* `when` no longer falls back to `() {} as T` on the initial state. `onInitial`
  remains optional and now defaults to `onLoading`.
* `Success` and `Failure` declare their value as non-nullable.

**Additions.**

* `SoAsync<F, S>` and `SoExceptionAsync<S>` for operations that are always
  asynchronous, and `SoSync<F, S>` and `SoExceptionSync<S>` for operations that
  never are. `So` and `SoException` stay `FutureOr` and are unchanged; the new
  aliases remove the `as Future<Do<...>>` cast that `Future.wait` and other
  `Future` members forced on callers.

## 1.1.2

* Fixed `tryCatch` method when onCatch is null.

## 1.1.1

* Added missing `orElse` in `maybeWhen` interface.

## 1.1.0

* Added `maybeWhen` method to handle specific states.

## 1.0.0

* Initial stable release
