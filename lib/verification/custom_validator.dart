import 'dart:io';

abstract class CustomValidator {
  bool validate(X509Certificate cert, String host, int port);
}
