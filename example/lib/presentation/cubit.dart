import 'package:doso/doso.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/repository.dart';

typedef MyState = Do<String>;

class MyCubit extends Cubit<MyState> {
  MyCubit(this.repository) : super(Do.initial());

  final Repository repository;

  Future<void> getOkStatusCode() async {
    emit(Do.loading());

    final result = await repository.getOk();
    return result.fold(
      onFailure: (failure, _) => emit(Do.failure(failure)),
      onSuccess: (statusCode) => emit(Do.success('Success: $statusCode')),
    );
  }

  Future<void> getNotFoundStatusCode() async {
    emit(Do.loading());

    final result = await repository.getNotFound();
    return result.fold(
      onFailure: (failure, _) => emit(Do.failure(failure)),
      onSuccess: (statusCode) => emit(Do.success(statusCode)),
    );
  }

  Future<void> getErrorStatusCode() async {
    emit(Do.loading());

    final result = await repository.getError();
    return result.fold(
      onFailure: (failure, _) => emit(Do.failure(failure)),
      onSuccess: (statusCode) => emit(Do.success(statusCode)),
    );
  }
}
