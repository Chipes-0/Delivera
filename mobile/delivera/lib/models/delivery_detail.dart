import '../utils/datetime_format.dart';

class DeliveryDetail {
  final String id;
  final String status;
  final String origin;
  final String destiny;
  final double? distance;
  final String receiverName;
  final String itemsDescription;
  final double? quantity;
  final String unity;
  final double? cargoValue;
  final String? assignedTo;
  final DateTime? createdAt;
  final DateTime? assignedAt;
  final DateTime? deliveredAt;

  const DeliveryDetail({
    required this.id,
    required this.status,
    required this.origin,
    required this.destiny,
    required this.distance,
    required this.receiverName,
    required this.itemsDescription,
    required this.quantity,
    required this.unity,
    required this.cargoValue,
    required this.assignedTo,
    required this.createdAt,
    required this.assignedAt,
    required this.deliveredAt,
  });

  String get formattedCreatedAt => formatDateTime(createdAt);

  factory DeliveryDetail.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '');
    }

    return DeliveryDetail(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
      destiny: json['destiny']?.toString() ?? '',
      distance: toDouble(json['distance']),
      receiverName: json['receiver_name']?.toString() ?? '',
      itemsDescription: json['items_description']?.toString() ?? '',
      quantity: toDouble(json['quantity']),
      unity: json['unity']?.toString() ?? '',
      cargoValue: toDouble(json['cargo_value']),
      assignedTo: json['assigned_to']?.toString(),
      createdAt: parseDateTime(json['created_at']),
      assignedAt: parseDateTime(json['assigned_at']),
      deliveredAt: parseDateTime(json['delivered_at']),
    );
  }
}

