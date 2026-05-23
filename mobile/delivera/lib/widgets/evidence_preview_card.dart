import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/evidence_item.dart';
import '../utils/datetime_format.dart';

class EvidencePreviewCard extends StatelessWidget {
  final EvidenceItem evidence;
  final VoidCallback? onTap;

  const EvidencePreviewCard({
    super.key,
    required this.evidence,
    this.onTap,
  });

  String get _formattedDate {
    final parsed = parseDateTime(evidence.createdAt);
    if (parsed != null) return formatDateTime(parsed);
    return evidence.createdAt ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    final previewBytes = evidence.photoBase64 ?? evidence.signatureBase64;
    final hasPreview = (previewBytes ?? '').isNotEmpty;
    final isSignature = (evidence.signatureBase64 ?? '').isNotEmpty;

    final card = Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasPreview)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.memory(
                    base64Decode(previewBytes!),
                    width: double.infinity,
                    height: 200,
                    fit: isSignature ? BoxFit.contain : BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 120,
                  color: const Color(0xFFF0F0F0),
                  child: const Center(
                    child: Icon(Icons.insert_drive_file_outlined),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evidence.title ?? 'Sin título',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formattedDate,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSignature
                    ? const Color(0xFF1F4FA3)
                    : const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                evidence.typeLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}
