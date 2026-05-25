import 'dart:convert';
import 'dart:io';

import '../session.dart';

class AuthApi {
  final Uri baseUri;

  const AuthApi({required this.baseUri});

  Future<void> login({required String name, required String password}) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(baseUri.resolve('/v1/auth/login'));
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.add(
        utf8.encode(jsonEncode({'name': name, 'password': password})),
      );

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 401) {
        throw HttpException('Credenciales inválidas', uri: request.uri);
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'HTTP ${response.statusCode}: $body',
          uri: request.uri,
        );
      }

      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Respuesta inválida');
      }
      final token = decoded['access_token'] as String?;
      if (token == null || token.isEmpty) {
        throw const FormatException('Sin access_token');
      }
      await Session.saveToken(token);
    } finally {
      client.close(force: true);
    }
  }
}
