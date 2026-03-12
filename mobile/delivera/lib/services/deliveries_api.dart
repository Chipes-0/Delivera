import 'dart:convert';
import 'dart:io';

import '../models/delivery_summary.dart';

class DeliveriesApi {
  final Uri baseUri;

  const DeliveriesApi({
    required this.baseUri,
  });

  Future<List<DeliverySummary>> listDeliveries() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(baseUri.resolve('/v1/deliveries/'));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');

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
            .map((m) => DeliverySummary.fromJson(m.cast<String, dynamic>()))
            .toList(growable: false);
      }

      return const <DeliverySummary>[];
    } finally {
      client.close(force: true);
    }
  }
}

