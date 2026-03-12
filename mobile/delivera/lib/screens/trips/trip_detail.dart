import 'package:flutter/material.dart';

import '../../models/delivery_detail.dart';
import '../../services/delivery_api.dart';
import '../evidence/evidence_list.dart';

class TripDetailPage extends StatelessWidget {
  final String deliveryId;

  const TripDetailPage({
    super.key,
    required this.deliveryId,
  });

  @override
  Widget build(BuildContext context) {
    final api = DeliveryApi(baseUri: Uri.parse('http://10.0.2.2:8000'));

    return Scaffold(
      appBar: AppBar(title: const Text('Viaje')),
      body: FutureBuilder<DeliveryDetail>(
        future: api.getDelivery(deliveryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No se pudo cargar el viaje.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString()),
                ],
              ),
            );
          }

          final d = snapshot.data;
          if (d == null) {
            return const Center(child: Text('Sin datos.'));
          }

          String kv(String label, String value) {
            if (value.isEmpty) return '$label: —';
            return '$label: $value';
          }

          String kvNum(String label, double? value) {
            return '$label: ${value?.toStringAsFixed(2) ?? '—'}';
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${d.origin} → ${d.destiny}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(kv('Status', d.status)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EvidenceListPage(deliveryId: deliveryId),
                    ),
                  );
                },
                child: const Text('Evidencias'),
              ),
              const SizedBox(height: 24),
              Text(
                'Resumen del viaje',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kv('ID', d.id)),
                      const SizedBox(height: 8),
                      Text(kvNum('Kms', d.distance)),
                      const SizedBox(height: 8),
                      Text(kv('Mercancía', d.itemsDescription)),
                      const SizedBox(height: 8),
                      Text(
                        'Cantidad: ${d.quantity?.toString() ?? '—'} ${d.unity.isEmpty ? '' : d.unity}',
                      ),
                      const SizedBox(height: 8),
                      Text(kv('Receptor', d.receiverName)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

