import 'dart:io';

abstract class HttpClientCreator {
  HttpClient create(Map<String, bool> fingerprints);
}
