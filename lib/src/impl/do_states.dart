part of 'do_handler.dart';

final class Initial<S> extends DoHandler<S> {
  const Initial();

  @override
  List<Object?> get props => [];
}

final class Loading<S> extends DoHandler<S> {
  const Loading();

  @override
  List<Object?> get props => [];
}

final class Success<S> extends DoHandler<S> {
  const Success(this._value);

  @override
  final S _value;

  @override
  List<Object?> get props => [_value];
}

final class Failure<S> extends DoHandler<S> {
  const Failure([this._exception, this._stackTrace]);

  @override
  final Exception? _exception;

  @override
  final StackTrace? _stackTrace;

  @override
  List<Object?> get props => [_exception, _stackTrace];
}
