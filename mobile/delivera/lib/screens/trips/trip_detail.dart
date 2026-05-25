import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../models/delivery_detail.dart';
import '../../utils/datetime_format.dart';
import '../../services/delivery_api.dart';
import '../../services/evidence_api.dart';
import '../../session.dart';
import '../evidence/evidence_list.dart';
import 'create_trip.dart';

class _TripViewData {
  final DeliveryDetail trip;
  final int evidenceCount;

  const _TripViewData({
    required this.trip,
    required this.evidenceCount,
  });
}

class TripDetailPage extends StatefulWidget {
  final String deliveryId;

  const TripDetailPage({
    super.key,
    required this.deliveryId,
  });

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  final _api = DeliveryApi(baseUri: AppConfig.apiBaseUri);
  final _evidenceApi = EvidenceApi(baseUri: AppConfig.apiBaseUri);
  late Future<_TripViewData> _future;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_TripViewData> _load() async {
    final results = await Future.wait([
      _api.getDelivery(widget.deliveryId),
      _evidenceApi.listEvidence(widget.deliveryId),
    ]);
    final trip = results[0] as DeliveryDetail;
    final evidence = results[1] as List;
    return _TripViewData(trip: trip, evidenceCount: evidence.length);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateTripPage(deliveryId: widget.deliveryId),
      ),
    );
    if (updated == true && mounted) {
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viaje actualizado')),
      );
    }
  }

  Future<void> _openEvidence() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvidenceListPage(deliveryId: widget.deliveryId),
      ),
    );
    if (mounted) _reload();
  }

  Future<void> _completeTrip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completar viaje'),
        content: const Text(
          '¿Marcar este viaje como completado? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Completar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _completing = true);
    try {
      await _api.completeDelivery(widget.deliveryId);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Viaje marcado como completado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo completar el viaje: $e')),
      );
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viaje'),
        actions: [
          if (Session.isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar viaje',
              onPressed: _openEdit,
            ),
        ],
      ),
      body: FutureBuilder<_TripViewData>(
        future: _future,
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

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Sin datos.'));
          }

          final d = data.trip;
          final isDelivered = d.status.toUpperCase() == 'DELIVERED';
          final canComplete = Session.isDriver &&
              !isDelivered &&
              data.evidenceCount >= 1;

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
              if (Session.isAdmin)
                OutlinedButton.icon(
                  onPressed: _openEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar viaje'),
                ),
              if (Session.isAdmin) const SizedBox(height: 12),
              if (canComplete)
                FilledButton.icon(
                  onPressed: _completing ? null : _completeTrip,
                  icon: _completing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: const Text('Marcar como completado'),
                ),
              if (canComplete) const SizedBox(height: 12),
              if (Session.isDriver && !isDelivered && data.evidenceCount < 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Registra al menos una evidencia para poder completar el viaje.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ElevatedButton(
                onPressed: _openEvidence,
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
                      Text(kv('Creado', d.formattedCreatedAt)),
                      if (d.deliveredAt != null) ...[
                        const SizedBox(height: 8),
                        Text(kv('Entregado', formatDateTime(d.deliveredAt))),
                      ],
                      const SizedBox(height: 8),
                      Text(kvNum('Kms', d.distance)),
                      const SizedBox(height: 8),
                      Text(kv('Mercancía', d.itemsDescription)),
                      const SizedBox(height: 8),
                      Text(
                        'Cantidad: ${d.quantity?.toString() ?? '—'} ${d.unity.isEmpty ? '' : d.unity}',
                      ),
                      const SizedBox(height: 8),
                      Text(kvNum('Valor de carga', d.cargoValue)),
                      const SizedBox(height: 8),
                      Text(kv('Receptor', d.receiverName)),
                      const SizedBox(height: 8),
                      Text('Evidencias: ${data.evidenceCount}'),
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
