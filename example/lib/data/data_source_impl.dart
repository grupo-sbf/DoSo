import 'dart:io';

import 'package:doso/doso.dart';
import 'package:example/data/fake_api.dart';

import '../domain/customs_failure.dart';
import 'data_source.dart';

class DataSourceImpl implements DataSource {
  const DataSourceImpl(this.http);

  final FakeNetwork http;

  @override
  So<NetworkFailure, int> getOk() => Do.tryCatch(
        onTry: () => http.get('/ok'),
      );

  @override
  So<NetworkFailure, int> getNotFound() => Do.tryCatch(
        onTry: () => http.get('/not-found'),
      );

  @override
  So<NetworkFailure, int> getInternalServerError() => Do.tryCatch(
        onTry: () => http.get('Okie dokie'),
        onCatch: (exception, stackTrace) {
          if (exception is HttpException) {
            return InternalServerErrorFailure();
          }

          return UnexpectedFailure();
        },
      );
}
