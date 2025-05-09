import 'package:doso/doso.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/customs_failure.dart';
import '../domain/repository.dart';

typedef MyState = Do<NetworkFailure, String>;

class MyCubit extends Cubit<MyState> {
  MyCubit(this.repository) : super(Do.initial());

  final Repository repository;

  Future<void> getOk() async {
    emit(Do.loading());

    final result = await repository.getOk();
    return result.fold(
      onFailure: (failure) => emit(Do.failure(failure)),
      onSuccess: (data) => emit(Do.success('Success: $data')),
    );
  }

  Future<void> getNotFound() async {
    emit(Do.loading());

    final result = await repository.getNotFound();
    return result.fold(
      onFailure: (failure) => emit(Do.failure(failure)),
      onSuccess: (data) => emit(Do.success(data)),
    );
  }

  Future<void> getInternalServer() async {
    emit(Do.loading());

    final result = await repository.getError();
    return result.fold(
      onFailure: (failure) => emit(Do.failure(failure)),
      onSuccess: (data) => emit(Do.success(data)),
    );
  }
}
