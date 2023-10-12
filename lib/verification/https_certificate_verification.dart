import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_certificate_pining/verification/certificate_fingerprint.dart';
import 'package:flutter_certificate_pining/verification/certificate_validator.dart';
import 'package:flutter_certificate_pining/verification/certificate_verification.dart';
import 'package:flutter_certificate_pining/verification/http_client_creator.dart';

class HttpsCertificateVerification implements CertificateVerification {
  final HttpClientCreator httpClientCreator;
  final CertificateValidator certificateValidator;
  final CertificateFingerprint certificateFingerprint;
  Map<String, bool> fingerprints = {};

  HttpsCertificateVerification(
    this.httpClientCreator,
    this.certificateValidator,
    this.certificateFingerprint,
  );

  @override
  void config(Dio dio) async {
    // Get certificate fingerprints
    if (fingerprints.isEmpty) {
      fingerprints = await certificateFingerprint.fingerprints();
    }

    // Create Http Client Adapter
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => httpClientCreator.create(fingerprints),
      validateCertificate: (cert, host, port) => certificateValidator
          .validateCertificate(cert, host, port, fingerprints),
    );
  }
}
