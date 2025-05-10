<div align="center">

<img src="logo.jpg" alt="doso logo" width="40%"/>

![Static Badge](https://img.shields.io/badge/coverage-87.3%25-green?link=https%3A%2F%2Fgithub.com%2Fgrupo-sbf%2FDoSo%2Ftree%2Fmain%2Fcoverage)
![Static Badge](https://img.shields.io/badge/version-v1.0.0-blue)
![Static Badge](https://img.shields.io/badge/License-MIT-blue)

</div>

# DoSo: Simple and Elegant Error and State Handling

**DoSo** is a lightweight Dart library designed to simplify and streamline state and error handling in Flutter applications. Built to reduce boilerplate and avoid code generation, DoSo provides a functional and expressive API for managing synchronous and asynchronous operations.

---

## 🚀 Getting Started

DoSo offers a declarative and functional approach to handling common states such as:

* `initial`
* `loading`
* `success`
* `failure`

This encapsulates logic and enhances error handling throughout your app.
Check out the example below to see how DoSo can be used in your Flutter projects.

```dart
import 'package:doso/doso.dart';

void main() async {
  // [Do] represents a action. (State with a value of type S and an optional failure of type F)
  // [So] represents a return. (Is a type alias for Do<F, S> and SoException<Exception, S> for a fixed failure type)
  
  // EMITTING STATES
  // Use Do.tryCatch to handle sync or async operations
  final result = await Do.tryCatch(
    onTry: () => doSomething(),
    onCatch: (exception, stackTrace) => Exception('Captured error: $exception and $stackTrace'), // optional
    onFinally: () => print('finished'), // optional
  );
  // or
  // Use Do states directly with a common try/catch
  try {
    final result = doSomething();
    return Do.success(result);
  } catch (e) {
    return Do.failure(e);
  } finally {
    print('finished');
  }

  // STATE HANDLING
  // Handle all Do states with when:
  result.when(
    onInitial: () => print('Initial State'), // optional
    onLoading: () => print('Loading...'),
    onSuccess: (value) => print('Success: $value'),
    onFailure: (failure) => print('Failure: $failure'),
  );
  // or
  // Handle only Do.success and Do.failure with fold:
  result.fold(
    onFailure: (failure) => print('Failure: $failure'),
    onSuccess: (value) => print('Success: $value'),
  );
  // or
  // Just use a simple if statement:
  if (result.isInitial) {}
  if (result.isLoading) {}
  if (result.isSuccess) {} 
  if (result.isFailure) {}
  
  // RETURN STATEMENTS
  // So with custom failure type
  final So<F, S> result = Do.success(42);
  
  // So with failure fixed exception type
  final SoException<Exception, S> result2 = Do.success(42);
}
```

### 📦 Available States

```dart
// Do
Do.initial();             // Represents the initial state
Do.loading();             // Represents a loading state
Do.success(value);        // Represents a success with the associated value [S]
Do.failure([failure]);    // Represents a failure with optional failure [F]

// So
So<F, S>                  // Represents a return statement with a failure of type F and a value of type S
SoException<Exception, S> // Represents a return statement with a fixed failure type of Exception and a value of type S
```

---

## 🔑 Core Methods

### `getOrElse(S defaultValue)`

Returns the value in `Do.success`, or the fallback value if it is not available.

```dart
final value = Do.success(42).getOrElse(0); // 42
```

### `map<T>(T Function(S value))`

Transforms the success value into another value.

```dart
final result = Do.success(42).map((value) => value.toString()); // Do<String>.success('42')
```

### `flatMap<T>(Do<T, F> Function(S value))`

Maps to another `Do` state.

```dart
final result = Do.success(42).flatMap((value) => Do.success(value.toString()));
```

### `fold<T>`

Handle success and failure.

```dart
final message = Do.success(42).fold(
  onFailure: (failure) => 'Error: $failure',
  onSuccess: (value) => 'Success: $value',
);
```

### `when<T>`

Handle all states.

```dart
final output = result.when(
  onInitial: () => 'Initial',
  onLoading: () => 'Loading...',
  onSuccess: (value) => 'Success: $value',
  onFailure: (failure) => 'Failure: $failure',
);
```

### `tryCatch`

Wraps synchronous/async calls in a `Do`, automatically catching exceptions.

```dart
final result = await Do.tryCatch(
  onTry: () async => 42,
  onCatch: (exception, stackTrace) => Exception('Handled: $exception and $stackTrace'),
  onFinally: () => print('Done'),
);
```

---

## 📚 Use in Application Layers

### ✅ Data Source

```dart
SoException<int> getOk() => Do.tryCatch(onTry: () => http.get('/ok'));
```

### ✅ Repository

```dart
SoException<String> getOk() async {
  final result = await dataSource.getOk();
  return result.map((code) => code.toString());
}
```
or

```dart
So<CustomFailure, String> getOk() async {
  final result = await dataSource.getOk();
  return result.flatMap((code) {
    if (code == is2XX() || code == is3XX()) {
      return Do.success(code.toString());
    } else {
      return Do.failure(CustomFailure('Error: $code'));
    }
  });
}
```

### ✅ Cubit

```dart
class MyCubit extends Cubit<Do<Exception, String>> {
  MyCubit(this.repo) : super(Do.initial());
  
  final Repository repo;

  Future<void> getData() async {
    emit(Do.loading());
    
    final result = await repo.getOk();
    result.fold(
      onFailure: (failure) => emit(Do.failure(failure)),
      onSuccess: (value) => emit(Do.success('Success: $value')),
    );
  }
}
```

### ✅ UI

```dart
BlocBuilder<MyCubit, Do<Exception, String>>(
  builder: (context, state) => state.when(
    onInitial: () => Text('Initial'),
    onLoading: () => CircularProgressIndicator(),
    onSuccess: (value) => Text(value),
    onFailure: (failure) => Text(failure.toString()),
  ),
)
```

Explore a practical example: [DoSo Example](https://github.com/grupo-sbf/DoSo/tree/main/example)

---

## ⚠️ When to Use DoSo

DoSo is ideal for simple screen states or flows with a clear success/failure logic. You can
combine it with other libraries like `flutter_bloc` or `provider` for state management.

> If your state grows in complexity (e.g., multiple fields, nested properties), you might want to adopt a more traditional and robust approach like using manually crafted classes or more advanced tools.

---

## DoSo is not:

- A replacement for functional programming libraries like `dartz` or `fpdart`. It is a simple and elegant solution for handling states and errors in a functional way, without the need for complex abstractions.
- A replacement for state management libraries like `flutter_bloc` or `provider`. It is a lightweight library that can be used in conjunction with these libraries to simplify state and error handling.

## 🔗 More Info & Contribute

Check out the full implementation, open issues, and contribute on GitHub: [DoSo on GitHub](https://github.com/grupo-sbf/DoSo)

---
