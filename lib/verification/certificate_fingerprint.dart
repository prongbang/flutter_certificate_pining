abstract class CertificateFingerprint {
  Future<List<String>> fingerprints();

  Future<Map<String, bool>> fingerprintsMap() async {
    final map = <String, bool>{};
    for (var fingerprint in await fingerprints()) {
      map[fingerprint] = true;
    }
    return map;
  }
}
