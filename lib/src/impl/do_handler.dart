import 'package:equatable/equatable.dart';

import '../do.dart';
import 'do_exception.dart';

part 'do_states.dart';

sealed class DoHandler<F, S> extends Equatable implements Do<F, S> {
  const DoHandler();

  S? get _value => null;

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
        onFailure: Do.failure,
        onSuccess: (value) => Do.success(mapper(value)),
      );

  @override
  Do<F, T> flatMap<T>(Do<F, T> Function(S value) mapper) => fold(
        onFailure: Do.failure,
        onSuccess: mapper,
      );

  @override
  T fold<T>({
    required T Function(F failure) onFailure,
    required T Function(S value) onSuccess,
  }) {
    final state = this;

    if (state is Success<F, S>) {
      return onSuccess(state._value);
    }

    if (state is Failure<F, S>) {
      return onFailure(state._failure);
    }

    throw DoException(
      type: DoExceptionType.invalidState,
      message: 'Invalid state: $this. Expected Do.success or Do.failure',
    );
  }

  @override
  T when<T>({
    T Function()? onInitial,
    required T Function() onLoading,
    required T Function(S value) onSuccess,
    required T Function(F failure) onFailure,
  }) {
    final state = this;

    return switch (state) {
      Initial() => (onInitial ?? onLoading)(),
      Loading() => onLoading(),
      Success<F, S>() => onSuccess(state._value),
      Failure<F, S>() => onFailure(state._failure),
    };
  }

  @override
  T? maybeWhen<T>({
    T Function()? onInitial,
    T Function()? onLoading,
    T Function(S value)? onSuccess,
    T Function(F failure)? onFailure,
    T Function()? orElse,
  }) {
    final state = this;

    return switch (state) {
      Initial() => onInitial?.call() ?? orElse?.call(),
      Loading() => onLoading?.call() ?? orElse?.call(),
      Success<F, S>() => onSuccess?.call(state._value) ?? orElse?.call(),
      Failure<F, S>() => onFailure?.call(state._failure) ?? orElse?.call(),
    };
  }
}
