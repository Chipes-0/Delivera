import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_config.dart';
import '../../models/delivery_detail.dart';
import '../../models/evidence_item.dart';
import '../../services/delivery_api.dart';
import '../../services/evidence_api.dart';
import '../../widgets/evidence_preview_card.dart';
import '../evidence/evidence_detail.dart';

class TripReportPage extends StatefulWidget {
  final String deliveryId;

  const TripReportPage({
    super.key,
    required this.deliveryId,
  });

  @override
  State<TripReportPage> createState() => _TripReportPageState();
}

class _TripReportPageState extends State<TripReportPage> {
  final _deliveryApi = DeliveryApi(baseUri: AppConfig.apiBaseUri);
  final _evidenceApi = EvidenceApi(baseUri: AppConfig.apiBaseUri);

  late Future<_ReportData> _future;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ReportData> _load() async {
    final delivery = await _deliveryApi.getDelivery(widget.deliveryId);
    final evidence = await _evidenceApi.listEvidence(widget.deliveryId);
    return _ReportData(delivery: delivery, evidence: evidence);
  }

  Future<void> _exportExcel(_ReportData data) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Reporte'];

      sheet.appendRow([TextCellValue('Delivery ID'), TextCellValue(data.delivery.id)]);
      sheet.appendRow([TextCellValue('Status'), TextCellValue(data.delivery.status)]);
      sheet.appendRow([TextCellValue('Origen'), TextCellValue(data.delivery.origin)]);
      sheet.appendRow([TextCellValue('Destino'), TextCellValue(data.delivery.destiny)]);
      sheet.appendRow([TextCellValue('Kms'), TextCellValue('${data.delivery.distance ?? ''}')]);
      sheet.appendRow([TextCellValue('Receptor'), TextCellValue(data.delivery.receiverName)]);
      sheet.appendRow([TextCellValue('Mercancía'), TextCellValue(data.delivery.itemsDescription)]);
      sheet.appendRow([TextCellValue('Cantidad'), TextCellValue('${data.delivery.quantity ?? ''} ${data.delivery.unity}')]);

      sheet.appendRow([TextCellValue('')]);
      sheet.appendRow([
        TextCellValue('Evidencias'),
      ]);
      sheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Tipo'),
        TextCellValue('Fecha'),
      ]);

      for (final e in data.evidence) {
        sheet.appendRow([
          TextCellValue(e.id.toString()),
          TextCellValue(e.typeLabel),
          TextCellValue(e.createdAt ?? ''),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) {
        throw const FormatException('No se pudo generar el Excel');
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/reporte_${data.delivery.id}.xlsx');
      await file.writeAsBytes(bytes, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Reporte del viaje ${data.delivery.id}',
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte de viaje')),
      body: FutureBuilder<_ReportData>(
        future: _future,
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

          final data = snapshot.data;
          if (data == null) return const Center(child: Text('Sin datos.'));

          final signatures = data.evidence
              .where((e) => (e.signatureBase64 ?? '').isNotEmpty)
              .toList();
          final photos = data.evidence
              .where((e) => (e.photoBase64 ?? '').isNotEmpty)
              .toList();

          Widget evidenceSection(List<EvidenceItem> items) {
            if (items.isEmpty) {
              return Text(
                '—',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  EvidencePreviewCard(
                    evidence: items[i],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EvidenceDetailPage(
                            evidence: items[i],
                            deliveryId: widget.deliveryId,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${data.delivery.origin} → ${data.delivery.destiny}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kms: ${data.delivery.distance ?? '—'}'),
                      const SizedBox(height: 8),
                      Text('Mercancía: ${data.delivery.itemsDescription.isEmpty ? '—' : data.delivery.itemsDescription}'),
                      const SizedBox(height: 8),
                      Text('Receptor: ${data.delivery.receiverName.isEmpty ? '—' : data.delivery.receiverName}'),
                      const SizedBox(height: 8),
                      Text('Status: ${data.delivery.status.isEmpty ? '—' : data.delivery.status}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Firmas', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              evidenceSection(signatures),
              const SizedBox(height: 16),
              Text('Fotos', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              evidenceSection(photos),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _exporting ? null : () => _exportExcel(data),
                  child: _exporting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Generar Excel'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportData {
  final DeliveryDetail delivery;
  final List<EvidenceItem> evidence;

  const _ReportData({
    required this.delivery,
    required this.evidence,
  });
}

