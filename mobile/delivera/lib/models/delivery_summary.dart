import '../utils/datetime_format.dart';

class DeliverySummary {
  final String id;
  final String status;
  final String origin;
  final String destiny;
  final DateTime? createdAt;

  const DeliverySummary({
    required this.id,
    required this.status,
    required this.origin,
    required this.destiny,
    required this.createdAt,
  });

  bool get isDelivered => status.toUpperCase() == 'DELIVERED';

  String get routeLabel {
    final from = origin.isEmpty ? '—' : origin;
    final to = destiny.isEmpty ? '—' : destiny;
    return '$from → $to';
  }

  String get formattedCreatedAt => formatDateTime(createdAt);

  factory DeliverySummary.fromJson(Map<String, dynamic> json) {
    return DeliverySummary(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
      destiny: json['destiny']?.toString() ?? '',
      createdAt: parseDateTime(json['created_at']),
    );
  }
}
