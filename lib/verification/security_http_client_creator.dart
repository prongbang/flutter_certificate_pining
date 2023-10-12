import 'dart:io';

import 'package:flutter_certificate_pinning/verification/certificate_trusted_configuration.dart';
import 'package:flutter_certificate_pinning/verification/certificate_validator.dart';
import 'package:flutter_certificate_pinning/verification/http_client_creator.dart';

class SecurityHttpClientCreator implements HttpClientCreator {
  final CertificateValidator certificateValidator;
  final CertificateTrustedConfiguration? certificateTrustedConfiguration;

  SecurityHttpClientCreator(
    this.certificateValidator, {
    this.certificateTrustedConfiguration,
  });

  @override
  HttpClient create(Map<String, bool> fingerprints) {
    // Don't trust any certificate just because their root cert is trusted.
    final securityContext = SecurityContext(withTrustedRoots: false);
    if (certificateTrustedConfiguration != null) {
      for (final certBytes in certificateTrustedConfiguration!.certificates()) {
        securityContext.setClientAuthoritiesBytes(certBytes);
      }
    }
    final client = HttpClient(context: securityContext);

    // You can test the intermediate / root cert here.
    client.badCertificateCallback = (cert, host, port) => certificateValidator
        .validateBadCertificate(cert, host, port, fingerprints);

    return client;
  }
}
