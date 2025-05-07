import 'package:doso/doso.dart';

abstract interface class DataSource {
  So<int> getOk();

  So<int> getNotFound();

  So<int> getInternalServerError();
}
