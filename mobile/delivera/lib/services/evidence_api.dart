import 'dart:convert';
import 'dart:io';

import '../models/evidence_item.dart';

class EvidenceApi {
  final Uri baseUri;

  const EvidenceApi({
    required this.baseUri,
  });

  Future<List<EvidenceItem>> listEvidence(String deliveryId) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(
        baseUri.resolve('/v1/evidence/delivery/$deliveryId/evidence'),
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

      if (data is List) {
        return data
            .whereType<Map>()
            .map((m) => EvidenceItem.fromJson(m.cast<String, dynamic>()))
            .toList(growable: false);
      }

      return const <EvidenceItem>[];
    } finally {
      client.close(force: true);
    }
  }

  Future<void> addEvidence({
    required String deliveryId,
    String? signatureBase64,
    String? photoBase64,
    String? title,
  }) async {
    final payload = <String, dynamic>{
      if ((signatureBase64 ?? '').isNotEmpty) 'signature': signatureBase64,
      if ((photoBase64 ?? '').isNotEmpty) 'photo': photoBase64,
      if ((title ?? '').isNotEmpty) 'title': title,
    };

    final client = HttpClient();
    try {
      final request = await client.postUrl(
        baseUri.resolve('/v1/evidence/delivery/$deliveryId/evidence'),
      );
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.add(utf8.encode(jsonEncode(payload)));

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'HTTP ${response.statusCode}: $body',
          uri: request.uri,
        );
      }
    } finally {
      client.close(force: true);
    }
  }
}

