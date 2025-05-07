import 'package:doso/doso.dart';

abstract interface class Repository {
  So<String> getOk();

  So<String> getNotFound();

  So<String> getError();
}
