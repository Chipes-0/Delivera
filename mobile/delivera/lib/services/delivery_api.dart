import 'dart:convert';
import 'dart:io';

import '../models/delivery_detail.dart';
import 'auth_header.dart';

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
      if (data is Map<String, dynamic>) {
        return DeliveryDetail.fromJson(data);
      }
      throw const FormatException('Unexpected response shape');
    } finally {
      client.close(force: true);
    }
  }

  Future<void> updateDelivery(
    String deliveryId,
    Map<String, dynamic> body,
  ) async {
    final client = HttpClient();
    try {
      final request = await client.putUrl(
        baseUri.resolve('/v1/deliveries/$deliveryId'),
      );
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
    } finally {
      client.close(force: true);
    }
  }

  Future<void> assignDelivery(String deliveryId, String driverId) async {
    final client = HttpClient();
    try {
      final uri = baseUri.resolve(
        '/v1/deliveries/$deliveryId/assign?driver_id=$driverId',
      );
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      applyBearer(request);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'HTTP ${response.statusCode}: $responseBody',
          uri: request.uri,
        );
      }
    } finally {
      client.close(force: true);
    }
  }

  Future<void> completeDelivery(String deliveryId) async {
    final client = HttpClient();
    try {
      final request = await client.putUrl(
        baseUri.resolve('/v1/deliveries/$deliveryId/complete'),
      );
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      applyBearer(request);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'HTTP ${response.statusCode}: $responseBody',
          uri: request.uri,
        );
      }
    } finally {
      client.close(force: true);
    }
  }
}

