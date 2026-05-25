import 'dart:io';

import '../session.dart';

void applyBearer(HttpClientRequest request) {
  final token = Session.accessToken;
  if (token != null && token.isNotEmpty) {
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
  }
}
