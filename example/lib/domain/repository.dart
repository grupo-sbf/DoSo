import 'package:doso/doso.dart';

import 'customs_failure.dart';

abstract interface class Repository {
  So<NetworkFailure, String> getOk();

  So<NetworkFailure, String> getNotFound();

  So<NetworkFailure, String> getError();
}
