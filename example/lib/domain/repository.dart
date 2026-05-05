import 'package:doso/doso.dart';

abstract interface class Repository {
  SoException<String> getOk();

  SoException<String> getNotFound();

  SoException<String> getError();
}
