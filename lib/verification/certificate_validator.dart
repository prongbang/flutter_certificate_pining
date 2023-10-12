import 'dart:io';

abstract class CertificateValidator {
  bool validateCertificate(
    X509Certificate? cert,
    String host,
    int port,
    Map<String, bool> fingerprints,
  );

  bool validateBadCertificate(
    X509Certificate cert,
    String host,
    int port,
    Map<String, bool> fingerprints,
  );
}
