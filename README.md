![Static Badge](https://img.shields.io/badge/coverage-87.3%25-green?link=https%3A%2F%2Fgithub.com%2Fgrupo-sbf%2FDoSo%2Ftree%2Fmain%2Fcoverage)
![Static Badge](https://img.shields.io/badge/version-v1.0.0-blue)
![Static Badge](https://img.shields.io/badge/License-MIT-blue)



# DoSo: Simple and Elegant Error and State Handling

**DoSo** is a lightweight Dart library designed to simplify and streamline state and error handling in Flutter applications. Built to reduce boilerplate and avoid code generation, DoSo provides a functional and expressive API for managing synchronous and asynchronous operations.

---

## 🔧 Installation

Add `doso` to your `pubspec.yaml`:

```yaml
dependencies:
  doso: ^1.0.0
```

Then run:

```bash
dart pub get
```

---

## 🚀 Getting Started

DoSo offers a declarative and functional approach to handling common states such as:

* `initial`
* `loading`
* `success`
* `failure`

This helps encapsulate logic and improves error management across your app.

### 📦 Available States

```dart
Do.initial();       // Represents the initial state
Do.loading();       // Represents a loading state
Do.success(value);  // Represents a success with the associated value [S]
Do.failure();       // Represents a failure with optional failure [F]
```

---

## 🔑 Core Methods

### `getOrElse(S defaultValue)`

Returns the value in `Do.success`, or the fallback if not available.

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

Combines all state branches into a single result.

```dart
final message = Do.success(42).fold(
  onFailure: (failure) => 'Error: $failure',
  onSuccess: (value) => 'Success: $value',
);
```

### `when<T>`

Executes based on the current state.

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
So<Exception, int> getOk() => Do.tryCatch(onTry: () => http.get('/ok'));
```

### ✅ Repository

```dart
So<Exception, String> getOk() async {
  final result = await dataSource.getOk();
  return result.map((code) => code.toString());
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

---

## ⚠️ When to Use DoSo

DoSo is ideal for simple screen states or flows with a clear success/failure logic.

> If your state grows in complexity (e.g., multiple fields, nested properties), you might want to adopt a more traditional and robust approach like using manually crafted classes or more advanced tools.

---

## 📎 Related Projects

* `flutter_bloc`
* `equatable`
* `freezed`
* `dartz`

---

## 🔗 More Info & Contribute

Check out the full implementation, open issues, and contribute on GitHub: [DoSo on GitHub](https://github.com/grupo-sbf/DoSo)

---
