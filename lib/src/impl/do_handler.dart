import 'package:equatable/equatable.dart';

import '../do.dart';
import 'do_exception.dart';

part 'do_states.dart';

sealed class DoHandler<F, S> extends Equatable implements Do<F, S> {
  const DoHandler();

  S? get _value => null;

  F? get _failure => null;

  @override
  bool get isInitial => this is Initial;

  @override
  bool get isLoading => this is Loading;

  @override
  bool get isSuccess => this is Success;

  @override
  bool get isFailure => this is Failure;

  @override
  S getOrElse(S defaultValue) => _value ?? defaultValue;

  @override
  Do<F, T> map<T>(T Function(S value) mapper) => fold(
        onFailure: (failure) => Do.failure(failure),
        onSuccess: (value) => Do.success(mapper(value)),
      );

  @override
  Do<F, T> flatMap<T>(Do<F, T> Function(S value) mapper) => fold(
        onFailure: (failure) => Do.failure(failure),
        onSuccess: (value) => mapper(value),
      );

  @override
  T fold<T>({
    required T Function(F failure) onFailure,
    required T Function(S value) onSuccess,
  }) =>
      switch (this) {
        Success() => onSuccess(_value as S),
        Failure() => onFailure(_failure as F),
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
    required T Function(F failure) onFailure,
  }) =>
      switch (this) {
        Initial() => onInitial?.call() ?? () {} as T,
        Loading() => onLoading(),
        Success() => onSuccess(_value as S),
        Failure() => onFailure(_failure as F),
      };

  @override
  T maybeWhen<T>({
    T Function()? onInitial,
    T Function()? onLoading,
    T Function(S value)? onSuccess,
    T Function(F failure)? onFailure,
    required T Function() orElse,
  }) =>
      switch (this) {
        Initial() => onInitial?.call() ?? orElse(),
        Loading() => onLoading?.call() ?? orElse(),
        Success() => onSuccess?.call(_value as S) ?? orElse(),
        Failure() => onFailure?.call(_failure as F) ?? orElse(),
      };

  @override
  T? whenOrNull<T>({
    T Function()? onInitial,
    T Function()? onLoading,
    T Function(S value)? onSuccess,
    T Function(F failure)? onFailure,
  }) =>
      switch (this) {
        Initial() => onInitial?.call(),
        Loading() => onLoading?.call(),
        Success() => onSuccess?.call(_value as S),
        Failure() => onFailure?.call(_failure as F),
      };
}
