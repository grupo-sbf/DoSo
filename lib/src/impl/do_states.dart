part of 'do_handler.dart';

final class Initial<F, S> extends DoHandler<F, S> {
  const Initial();

  @override
  List<Object?> get props => [];
}

final class Loading<F, S> extends DoHandler<F, S> {
  const Loading();

  @override
  List<Object?> get props => [];
}

final class Success<F, S> extends DoHandler<F, S> {
  const Success(this._value);

  @override
  final S _value;

  @override
  List<Object?> get props => [_value];
}

final class Failure<F, S> extends DoHandler<F, S> {
  const Failure([this._failure]);

  @override
  final F? _failure;

  @override
  List<Object?> get props => [_failure];
}
