import 'package:equatable/equatable.dart';

import '../do.dart';
import 'do_exception.dart';

part 'do_states.dart';

sealed class DoHandler<S> extends Equatable implements Do<S> {
  const DoHandler();

  S? get _value => null;

  Exception? get _exception => null;

  StackTrace? get _stackTrace => null;

  @override
  bool get isInitial => this is Initial<S>;

  @override
  bool get isLoading => this is Loading<S>;

  @override
  bool get isSuccess => this is Success<S>;

  @override
  bool get isFailure => this is Failure<S>;

  @override
  S getOrElse(S defaultValue) => _value ?? defaultValue;

  @override
  Do<T> map<T>(T Function(S value) mapper) => switch (this) {
        Success() => Do.success(mapper(_value as S)),
        Failure() => Do.failure(_exception, _stackTrace),
        _ => throw DoException(
            type: DoExceptionType.invalidState,
            message: 'Invalid state: $this. Expected Do.success or Do.failure',
          ),
      };

  @override
  Do<T> flatMap<T>(Do<T> Function(S value) mapper) => switch (this) {
        Success() => mapper(_value as S),
        Failure() => Do.failure(_exception, _stackTrace),
        _ => throw DoException(
            type: DoExceptionType.invalidState,
            message: 'Invalid state: $this. Expected Do.success or Do.failure',
          ),
      };

  @override
  T fold<T>({
    required T Function(Exception? exception, StackTrace? stackTrace) onFailure,
    required T Function(S value) onSuccess,
  }) =>
      switch (this) {
        Success() => onSuccess(_value as S),
        Failure() => onFailure(_exception, _stackTrace),
        _ => throw DoException(
            type: DoExceptionType.invalidState,
            message: 'Invalid state: $this. Expected Do.success or Do.failure',
          ),
      };

  @override
  T when<T>({
    T Function()? onInitial,
    required T Function() onLoading,
    required T Function(S value) onSuccess,
    required T Function(Exception? exception, StackTrace? stackTrace) onFailure,
  }) =>
      switch (this) {
        Initial() => onInitial?.call() ?? () {} as T,
        Loading() => onLoading(),
        Success() => onSuccess(_value as S),
        Failure() => onFailure(_exception, _stackTrace),
      };
}
