class DeliverySummary {
  final String id;
  final String status;

  const DeliverySummary({
    required this.id,
    required this.status,
  });

  factory DeliverySummary.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final statusRaw = json['status'];

    return DeliverySummary(
      id: idRaw?.toString() ?? '',
      status: statusRaw?.toString() ?? '',
    );
  }
}

