class EvidenceItem {
  final int id;
  final String deliveryId;
  final String? signatureBase64;
  final String? photoBase64;
  final String? createdAt;

  const EvidenceItem({
    required this.id,
    required this.deliveryId,
    required this.signatureBase64,
    required this.photoBase64,
    required this.createdAt,
  });

  factory EvidenceItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return EvidenceItem(
      id: parseInt(json['id']),
      deliveryId: json['delivery_id']?.toString() ?? '',
      signatureBase64: json['signature']?.toString(),
      photoBase64: json['photo']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  String get typeLabel {
    if ((signatureBase64 ?? '').isNotEmpty) return 'Firma';
    if ((photoBase64 ?? '').isNotEmpty) return 'Foto';
    return 'Evidencia';
  }
}

