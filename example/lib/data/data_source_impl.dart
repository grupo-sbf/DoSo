import 'dart:io';

import 'package:doso/doso.dart';
import 'package:example/data/fake_api.dart';

import '../domain/custom_exception.dart';
import 'data_source.dart';

class DataSourceImpl implements DataSource {
  const DataSourceImpl(this.http);

  final FakeNetwork http;

  @override
  So<int> getOk() => Do.tryCatch(
        onTry: () => http.get('/ok'),
      );

  @override
  So<int> getNotFound() => Do.tryCatch(
        onTry: () => http.get('/not-found'),
      );

  @override
  So<int> getInternalServerError() => Do.tryCatch(
        onTry: () => http.get('Okie dokie'),
        onCatch: (exception, stackTrace) {
          if (exception is HttpException) {
            return CustomException(
              'Ops! We have internal server error',
              exception: exception,
              stackTrace: stackTrace,
            );
          }

          return CustomException(
            'Ops! We have an error',
            exception: exception,
            stackTrace: stackTrace,
          );
        },
      );
}
