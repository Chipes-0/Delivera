import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../models/delivery_summary.dart';
import '../../services/deliveries_api.dart';
import '../../widgets/trip_summary_tile.dart';
import 'trip_report.dart';

class CompletedTripsPage extends StatelessWidget {
  const CompletedTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final api = DeliveriesApi(baseUri: AppConfig.apiBaseUri);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: FutureBuilder<List<DeliverySummary>>(
        future: api.listDeliveries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text(snapshot.error.toString()),
            );
          }

          final all = snapshot.data ?? const <DeliverySummary>[];
          final done = all
              .where((d) => d.status.toUpperCase() == 'DELIVERED')
              .toList(growable: false);

          if (done.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No hay viajes terminados (DELIVERED).'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: done.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final trip = done[index];
              return TripSummaryTile(
                trip: trip,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripReportPage(deliveryId: trip.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

