import 'package:intl/intl.dart';

DateTime? parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    if (value > 9999999999) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
  }
  return DateTime.tryParse(value.toString());
}

String formatDateTime(DateTime? value) {
  if (value == null) return 'Fecha no disponible';
  return DateFormat('dd/MM/yyyy HH:mm').format(value.toLocal());
}
