import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_certificate_pinning/verification/certificate_validator.dart';
import 'package:flutter_certificate_pinning/verification/custom_validator.dart';

class SelfCertificateValidator implements CertificateValidator {
  final CustomValidator customValidator;

  SelfCertificateValidator(this.customValidator);

  @override
  bool validateCertificate(
    X509Certificate? cert,
    String host,
    int port,
    Map<String, bool> fingerprints,
  ) {
    // Check that the cert fingerprint matches the one we expect.
    if (cert == null) {
      return false;
    }
    // Validate it any way you want.
    final fingerprint = sha256.convert(cert.der).toString();
    if (fingerprint.isEmpty) {
      return false;
    }

    // Validate
    final hasMatches = customValidator.validate(cert, host, port);

    return (fingerprints[fingerprint] == true) && hasMatches;
  }

  @override
  bool validateBadCertificate(
    X509Certificate cert,
    String host,
    int port,
    Map<String, bool> fingerprints,
  ) {
    // Certificate Authority Verification
    final fingerprint = sha256.convert(cert.der).toString();
    if (fingerprint.isEmpty) {
      return false;
    }

    // Validate
    final hasMatches = customValidator.validate(cert, host, port);

    return (fingerprints[fingerprint] == true) && hasMatches;
  }
}
