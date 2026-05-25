class Driver {
  final String id;
  final String name;

  const Driver({
    required this.id,
    required this.name,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
