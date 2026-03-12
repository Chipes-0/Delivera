import 'dart:convert';
import 'dart:io';

import '../models/delivery_detail.dart';

class DeliveryApi {
  final Uri baseUri;

  const DeliveryApi({
    required this.baseUri,
  });

  Future<DeliveryDetail> getDelivery(String deliveryId) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(
        baseUri.resolve('/v1/deliveries/$deliveryId'),
      );
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
      if (data is Map<String, dynamic>) {
        return DeliveryDetail.fromJson(data);
      }
      throw const FormatException('Unexpected response shape');
    } finally {
      client.close(force: true);
    }
  }
}

