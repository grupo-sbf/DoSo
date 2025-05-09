import 'package:doso/doso.dart';

import '../domain/customs_failure.dart';
import '../domain/repository.dart';
import 'data_source.dart';

class RepositoryImpl implements Repository {
  const RepositoryImpl(this.dataSource);

  final DataSource dataSource;

  @override
  So<NetworkFailure, String> getOk() async {
    final result = await dataSource.getOk();
    return result.map((data) => data.toString());
  }

  @override
  So<NetworkFailure, String> getNotFound() async {
    final result = await dataSource.getNotFound();
    return result.flatMap(
      (_) => Do.failure(NotFoundFailure()),
    );
  }

  @override
  So<NetworkFailure, String> getError() async {
    final result = await dataSource.getInternalServerError();
    return result.map((data) => data.toString());
  }
}
