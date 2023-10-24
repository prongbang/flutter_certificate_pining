# flutter_certificate_pinning

[![pub package](https://img.shields.io/pub/v/flutter_certificate_pinning.svg)](https://pub.dartlang.org/packages/flutter_certificate_pinning)

HTTPS certificate verification or public key pinning for Dio.

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/prongbang)

## How to use

- Get SHA256 Certificate Fingerprint from Unit Test

```shell
flutter test test/flutter_certificate_pinning_test.dart
```

Output

```shell
ExpiredAt: Dec 11 08:19:25 2023 GMT
Fingerprints: [b235f7c569490f2b2b861d2237e303337fe45a80ffec55dc140abda69e843d51]
```

- SHA256 Certificate Fingerprint

```dart
class Sha256CertificateFingerprint extends CertificateFingerprint {
  @override
  Future<List<String>> fingerprints() async {
    return [
      // ExpiredAt: Dec 11 08:19:25 2023 GMT
      'b235f7c569490f2b2b861d2237e303337fe45a80ffec55dc140abda69e843d51',
    ];
  }
}
```

- Custom Validator

```dart
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
```

- Certificate Trusted Configuration

```dart
class LocalCertificateTrustedConfiguration implements CertificateTrustedConfiguration {
  @override
  List<List<int>> certificates() {
    // Certificate bytes
    return [];
  }
}
```

- Using

```dart
final certificateTrustedConfiguration = LocalCertificateTrustedConfiguration();
final sha256CertificateFingerprint = Sha256CertificateFingerprint();
final selfCustomValidator = SelfCustomValidator();
final certificateValidator = SelfCertificateValidator(selfCustomValidator);
final securityHttpClientCreator = SecurityHttpClientCreator(
  certificateValidator,
  certificateTrustedConfiguration: certificateTrustedConfiguration,
);
final httpsCertificateVerification = HttpsCertificateVerification(
  securityHttpClientCreator,
  certificateValidator,
  sha256CertificateFingerprint,
);
final dio = Dio();
httpsCertificateVerification.config(dio);
```