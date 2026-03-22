import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

import '../../services/evidence_api.dart';
import 'evidence_list.dart';

class EvidenceCapturePage extends StatefulWidget {
  final String deliveryId;
  final EvidenceCaptureMode mode;

  const EvidenceCapturePage({
    super.key,
    required this.deliveryId,
    required this.mode,
  });

  @override
  State<EvidenceCapturePage> createState() => _EvidenceCapturePageState();
}

class _EvidenceCapturePageState extends State<EvidenceCapturePage> {
  final _api = EvidenceApi(baseUri: Uri.parse('http://10.0.2.2:8000'));
  final _signature = SignatureController(
    penStrokeWidth: 3,
    penColor: const Color(0xFF1F4FA3),
    exportBackgroundColor: Colors.white,
  );
  final TextEditingController _titleController = TextEditingController();

  Uint8List? _previewBytes;
  bool _posting = false;

  @override
  void dispose() {
    _signature.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotoFromCamera() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() => _previewBytes = bytes);
  }

  Future<void> _pickPhotoFromGallery() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (xfile == null) return;
    final bytes = await xfile.readAsBytes();
    setState(() => _previewBytes = bytes);
  }

  Future<void> _pickAnyFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    final bytes = result?.files.single.bytes;
    if (bytes == null) return;
    setState(() => _previewBytes = bytes);
  }

  Future<void> _clear() async {
    if (widget.mode == EvidenceCaptureMode.signature) {
      _signature.clear();
      setState(() => _previewBytes = null);
      return;
    }
    setState(() => _previewBytes = null);
  }

  Future<void> _post() async {
    if (_posting) return;

    String? signatureBase64;
    String? photoBase64;
    final now = DateTime.now();
    final createdAt = now.toIso8601String();

    if (widget.mode == EvidenceCaptureMode.signature) {
      final bytes = await _signature.toPngBytes();
      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Primero captura una firma.')),
        );
        return;
      }
      signatureBase64 = base64Encode(bytes);
      setState(() => _previewBytes = bytes);
    } else {
      if (_previewBytes == null || _previewBytes!.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Primero selecciona o toma una foto.')),
        );
        return;
      }
      photoBase64 = base64Encode(_previewBytes!);
    }
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio.')),
      );
      return;
    }
    setState(() => _posting = true);
    try {
      await _api.addEvidence(
          deliveryId: widget.deliveryId,
          signatureBase64: signatureBase64,
          photoBase64: photoBase64,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar: $e')),
      );
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignature = widget.mode == EvidenceCaptureMode.signature;
    final title = isSignature ? 'Capturar firma' : 'Capturar foto';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Tipo de evidencia: ${isSignature ? 'Firma' : 'Foto'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (isSignature)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D6DB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Signature(
                    controller: _signature,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickAnyFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Seleccionar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickPhotoFromGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Galería'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _pickPhotoFromCamera,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Cámara'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Firma recibido / Foto paquete',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            'Vista previa',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            height: 220,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D6DB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _previewBytes == null
                ? const Center(child: Text('Sin vista previa.'))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _previewBytes!,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _posting ? null : _clear,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE0E5EA),
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _posting ? null : _post,
                  child: _posting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Añadir evidencia'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

