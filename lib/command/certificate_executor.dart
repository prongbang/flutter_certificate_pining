import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/services.dart';

abstract class CertificateExecutor {
  Future<bool> getCertificateByDomain(String domain, String filepath);

  Future<String> getFingerprintByDomain(String domain);

  Future<String> getFingerprintByFile(String filepath);

  Future<String> getExpiredByDomain(String domain);

  Future<String> getExpiredByFile(String filepath);

  Future<List<String>> getFingerprintList({
    String? domain,
    required String filepath,
  });

  Future<List<String>> parseToList(String path, {String? packageName});
}

class LocalCertificateExecutor implements CertificateExecutor {
  @override
  Future<bool> getCertificateByDomain(String domain, String filepath) async {
    final p = await Process.run('bash', [
      '-c',
      "openssl s_client -showcerts -connect $domain:443 -servername $domain 2>/dev/null </dev/null |  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $filepath",
    ]);
    if (p.exitCode == 0) {
      return true;
    }
    return false;
  }

  @override
  Future<String> getExpiredByDomain(String domain) async {
    final p = await Process.run('bash', [
      '-c',
      'openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -noout -dates',
    ]);
    String notAfterStr = '';
    if (p.exitCode == 0) {
      notAfterStr = p.stdout.toString();
      if (notAfterStr.startsWith('notAfter=')) {
        notAfterStr = notAfterStr.substring('notAfter='.length);
      }
    }
    return notAfterStr.replaceAll('\n', '');
  }

  @override
  Future<String> getExpiredByFile(String filepath) async {
    final p = await Process.run('bash', [
      '-c',
      'openssl x509 -enddate -noout -in $filepath',
    ]);
    String notAfterStr = '';
    if (p.exitCode == 0) {
      notAfterStr = p.stdout.toString();
      if (notAfterStr.startsWith('notAfter=')) {
        notAfterStr = notAfterStr.substring('notAfter='.length);
      }
    }
    return notAfterStr.replaceAll('\n', '');
  }

  @override
  Future<String> getFingerprintByDomain(String domain) async {
    final p = await Process.run('bash', [
      '-c',
      'openssl s_client -servername $domain -connect $domain:443 < /dev/null 2>/dev/null | openssl x509 -noout -fingerprint -sha256'
    ]);
    String fingerprint = '';
    if (p.exitCode == 0) {
      fingerprint = p.stdout
          .toString()
          .replaceAll('sha256 Fingerprint=', '')
          .replaceAll(':', '')
          .toLowerCase();
    }
    return fingerprint.replaceAll('\n', '');
  }

  @override
  Future<String> getFingerprintByFile(String filepath) async {
    final p = await Process.run('bash', [
      '-c',
      'openssl x509 -noout -fingerprint -sha256 -inform pem -in $filepath',
    ]);
    String fingerprint = '';
    if (p.exitCode == 0) {
      fingerprint = p.stdout
          .toString()
          .replaceAll('sha256 Fingerprint=', '')
          .replaceAll(':', '')
          .toLowerCase();
    }
    return fingerprint.replaceAll('\n', '');
  }

  @override
  Future<List<String>> parseToList(String path, {String? packageName}) async {
    if (packageName != null) {
      path = '$packageName/$path';
    }
    final certificatesString = await rootBundle.loadString(path);
    final List<String> certificatesList = certificatesString
        .split('-----END CERTIFICATE-----')
        .where((cert) => cert.contains('-----BEGIN CERTIFICATE-----'))
        .map((cert) => '${cert.trim()}\r\n-----END CERTIFICATE-----')
        .toList();
    return certificatesList;
  }

  @override
  Future<List<String>> getFingerprintList({
    String? domain,
    required String filepath,
  }) async {
    final fingerprints = <String>[];
    List<String> certificatesList = [];
    if (domain != null) {
      await getCertificateByDomain(domain, filepath);
    }
    certificatesList = await parseToList(filepath);
    for (final cert in certificatesList) {
      final x509RootCert = X509Utils.x509CertificateFromPem(cert);
      final fingerprint = x509RootCert.sha256Thumbprint?.toLowerCase();
      if (fingerprint != null) {
        fingerprints.add(fingerprint);
      }
    }

    String fingerprint = '';
    if (domain != null) {
      fingerprint = await getFingerprintByDomain(domain);
      final expiredAt = await getExpiredByDomain(domain);
      print('ExpiredAt: $expiredAt');
    } else {
      fingerprint = await getFingerprintByFile(filepath);
      final expiredAt = await getExpiredByFile(filepath);
      print('ExpiredAt: $expiredAt');
    }

    // Append when fingerprint is not exist
    if (!fingerprints.contains(fingerprint)) {
      fingerprints.add(fingerprint);
    }

    return fingerprints;
  }
}
