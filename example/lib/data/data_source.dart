import 'package:doso/doso.dart';

import '../domain/customs_failure.dart';

abstract interface class DataSource {
  So<NetworkFailure, int> getOk();

  So<NetworkFailure, int> getNotFound();

  So<NetworkFailure, int> getInternalServerError();
}
