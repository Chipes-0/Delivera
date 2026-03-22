import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/evidence_item.dart';
import '../../services/evidence_api.dart';

class EvidenceDetailPage extends StatefulWidget {
  final EvidenceItem evidence;
  final String deliveryId;

  const EvidenceDetailPage({
    super.key,
    required this.evidence,
    required this.deliveryId,
  });

  @override
  State<EvidenceDetailPage> createState() => _EvidenceDetailPageState();
}

class _EvidenceDetailPageState extends State<EvidenceDetailPage> {
  final _api = EvidenceApi(baseUri: Uri.parse('http://10.0.2.2:8000'));
  bool _deleting = false;

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar evidencia'),
        content: const Text('¿Estás seguro de que deseas eliminar esta evidencia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await _api.deleteEvidence(
        deliveryId: widget.deliveryId,
        evidenceId: widget.evidence.id,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evidencia eliminada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewBytes = widget.evidence.photoBase64 ?? widget.evidence.signatureBase64;
    final hasPreview = (previewBytes ?? '').isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Evidencia'),
        actions: [
          IconButton(
            onPressed: _deleting ? null : _delete,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasPreview)
              Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[200],
                child: Image.memory(
                  base64Decode(previewBytes!),
                  fit: BoxFit.contain,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.insert_drive_file_outlined, size: 64),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo de evidencia
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (widget.evidence.signatureBase64 ?? '').isNotEmpty
                          ? const Color(0xFF1F4FA3)
                          : const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.evidence.typeLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Título
                  Text(
                    'Título',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.evidence.title ?? 'Sin título',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Fecha de creación
                  Text(
                    'Fecha de creación',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(widget.evidence.createdAt),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  // ID
                  Text(
                    'ID de Evidencia',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.evidence.id.toString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Delivery ID
                  Text(
                    'ID de Entrega',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.evidence.deliveryId,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
