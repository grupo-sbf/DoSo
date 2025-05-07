import 'package:doso/doso.dart';
import 'package:example/domain/custom_exception.dart';

import '../domain/repository.dart';
import 'data_source.dart';

class RepositoryImpl implements Repository {
  const RepositoryImpl(this.dataSource);

  final DataSource dataSource;

  @override
  So<String> getOk() async {
    final result = await dataSource.getOk();
    return result.map((statusCode) => statusCode.toString());
  }

  @override
  So<String> getNotFound() async {
    final result = await dataSource.getNotFound();
    return result.flatMap(
      (statusCode) => Do.failure(
        CustomException(
          'Ops! Not found the resource',
        ),
      ),
    );
  }

  @override
  So<String> getError() async {
    final result = await dataSource.getInternalServerError();
    return result.map((statusCode) => statusCode.toString());
  }
}
