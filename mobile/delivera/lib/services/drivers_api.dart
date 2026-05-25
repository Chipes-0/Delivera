import 'dart:convert';
import 'dart:io';

import '../models/driver.dart';
import 'auth_header.dart';

class DriversApi {
  final Uri baseUri;

  const DriversApi({required this.baseUri});

  Future<List<Driver>> listDrivers() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(baseUri.resolve('/v1/drivers/'));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      applyBearer(request);

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'HTTP ${response.statusCode}: $body',
          uri: request.uri,
        );
      }

      final decoded = jsonDecode(body);
      final data = (decoded is Map<String, dynamic>) ? decoded['data'] : null;

      if (data is List) {
        return data
            .whereType<Map>()
            .map((m) => Driver.fromJson(m.cast<String, dynamic>()))
            .toList(growable: false);
      }

      return const <Driver>[];
    } finally {
      client.close(force: true);
    }
  }
}
