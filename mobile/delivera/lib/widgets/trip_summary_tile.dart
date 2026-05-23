import 'package:flutter/material.dart';

import '../models/delivery_summary.dart';

class TripSummaryTile extends StatelessWidget {
  final DeliverySummary trip;
  final VoidCallback onTap;

  const TripSummaryTile({
    super.key,
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivered = trip.isDelivered;
    final backgroundColor =
        isDelivered ? const Color(0xFFE8F5E9) : const Color(0xFFFFF9C4);
    final accentColor =
        isDelivered ? const Color(0xFF2E7D32) : const Color(0xFFF9A825);
    final statusLabel = isDelivered ? 'Completado' : 'Pendiente';

    return Card(
      elevation: 0,
      color: backgroundColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accentColor.withValues(alpha: 0.45)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: accentColor.withValues(alpha: 0.15),
          child: Icon(
            isDelivered ? Icons.check_circle_outline : Icons.schedule,
            color: accentColor,
          ),
        ),
        title: Text(
          trip.routeLabel,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(trip.formattedCreatedAt),
            const SizedBox(height: 2),
            Text(
              statusLabel,
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: accentColor),
        onTap: onTap,
      ),
    );
  }
}
