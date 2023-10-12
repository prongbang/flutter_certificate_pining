import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_certificate_pining/flutter_certificate_pining.dart';
import 'package:flutter_test/flutter_test.dart';

class SelfCustomValidator implements CustomValidator {
  @override
  bool validate(X509Certificate cert, String host, int port) {
    final hostMatches = _validateHost(host);

    return hostMatches;
  }

  bool _validateHost(String host) {
    return 'google.com' == host;
  }
}

class Sha256CertificateFingerprint implements CertificateFingerprint {
  @override
  Future<Map<String, bool>> fingerprints() async {
    return {
      // ExpiredAt: Dec 11 08:19:25 2023 GMT
      'b235f7c569490f2b2b861d2237e303337fe45a80ffec55dc140abda69e843d51': true,
    };
  }
}

class LocalCertificateTrustedConfiguration
    implements CertificateTrustedConfiguration {
  @override
  List<List<int>> certificates() {
    // Certificate bytes
    return [];
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late CertificateExecutor certificateExecutor;

  setUp(() {
    certificateExecutor = LocalCertificateExecutor();
  });

  test(
    'Should return fingerprint list for when get fingerprint success',
    () async {
      // Given
      const filepath = 'assets/google.com.cer';

      // When
      final fingerprints =
          await certificateExecutor.getFingerprintList(filepath: filepath);

      // Then
      print('Fingerprints: $fingerprints');
      expect(fingerprints, isNotEmpty);
    },
  );
}
