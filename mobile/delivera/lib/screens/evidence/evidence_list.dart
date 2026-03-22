import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/evidence_item.dart';
import '../../services/evidence_api.dart';
import 'evidence_capture.dart';

class EvidenceListPage extends StatefulWidget {
  final String deliveryId;

  const EvidenceListPage({
    super.key,
    required this.deliveryId,
  });

  @override
  State<EvidenceListPage> createState() => _EvidenceListPageState();
}

class _EvidenceListPageState extends State<EvidenceListPage> {
  final _api = EvidenceApi(baseUri: Uri.parse('http://10.0.2.2:8000'));
  late Future<List<EvidenceItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.listEvidence(widget.deliveryId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _api.listEvidence(widget.deliveryId);
    });
    await _future;
  }

  Future<void> _openAddModal() async {
    final choice = await showModalBottomSheet<EvidenceCaptureMode>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Firma'),
                onTap: () => Navigator.pop(context, EvidenceCaptureMode.signature),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Foto'),
                onTap: () => Navigator.pop(context, EvidenceCaptureMode.photo),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (!mounted || choice == null) return;

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EvidenceCapturePage(
          deliveryId: widget.deliveryId,
          mode: choice,
        ),
      ),
    );

    if (created == true) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencias'),
        actions: [
          IconButton(
            onPressed: _openAddModal,
            icon: const Icon(Icons.add),
            tooltip: 'Añadir',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<EvidenceItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'No se pudieron cargar las evidencias.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString()),
                ],
              );
            }

            final items = snapshot.data ?? const <EvidenceItem>[];
            if (items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  Text('Aún no hay evidencias.'),
                  SizedBox(height: 8),
                  Text('Pulsa “Añadir” para registrar una firma o foto.'),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final e = items[index];
                final previewBytes = (e.photoBase64 ?? e.signatureBase64);
                final hasPreview = (previewBytes ?? '').isNotEmpty;

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: hasPreview
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(previewBytes!),
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.insert_drive_file_outlined),
                    title: Text(
                      e.title ?? 'Sin título',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(e.createdAt ?? '—'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

enum EvidenceCaptureMode {
  signature,
  photo,
}

