## 2.0.0

* Breaking changes:
   * Changed the `So` structure generic constraint to `F extends Exception`.
   * Updated `Do` to use `Do<F extends Exception, S>`.
   * Changed `tryCatch` failure conversion semantics; code that relied on the previous failure mapping/conversion behavior must be reviewed and updated.
   * Changed the return types of `map` and `flatMap`; consumers may need to update type annotations and chained calls that depended on the previous return types.
* Migration notes:
   * Update generic type arguments and bounds anywhere `So` or `Do` are referenced so the failure type extends `Exception`.
   * Review `tryCatch` call sites, especially custom `onCatch` handling and any code that depended on the old failure conversion behavior.
   * Revisit usages of `map` and `flatMap` and adjust expected types, variable declarations, and fluent chains to match the new signatures.

## 1.1.2

* Fixed `tryCatch` method when onCatch is null.

## 1.1.1

* Added missing `orElse` in `maybeWhen` interface.

## 1.1.0

* Added `maybeWhen` method to handle specific states.

## 1.0.0

* Initial stable release
