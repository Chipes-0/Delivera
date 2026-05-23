import 'dart:convert';
import 'dart:io';

import '../models/delivery_summary.dart';
import 'auth_header.dart';

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
            .map((m) => DeliverySummary.fromJson(m.cast<String, dynamic>()))
            .toList(growable: false);
      }

      return const <DeliverySummary>[];
    } finally {
      client.close(force: true);
    }
  }

  Future<String> createDelivery(Map<String, dynamic> body) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(baseUri.resolve('/v1/deliveries/'));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      applyBearer(request);
      request.add(utf8.encode(jsonEncode(body)));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'HTTP ${response.statusCode}: $responseBody',
          uri: request.uri,
        );
      }

      final decoded = jsonDecode(responseBody);
      final data = (decoded is Map<String, dynamic>) ? decoded['data'] : null;
      if (data is Map<String, dynamic>) {
        return data['id']?.toString() ?? '';
      }
      throw const FormatException('Respuesta inesperada al crear el viaje');
    } finally {
      client.close(force: true);
    }
  }
}

