// lib/src/features/library/library_import_export_screen.dart
//
// L10.3: Export/import library metadata as JSON or CSV.

import 'dart:async' show unawaited;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../core/library/library_import_export_service.dart';
import '../../core/widgets/sunfire_badge.dart';
import '../../ui/design_system/components/components.dart' show SunfireButton;

class LibraryImportExportScreen extends StatefulWidget {
  const LibraryImportExportScreen({super.key});

  @override
  State<LibraryImportExportScreen> createState() =>
      _LibraryImportExportScreenState();
}

class _LibraryImportExportScreenState extends State<LibraryImportExportScreen> {
  bool _busy = false;
  String? _status;

  Future<void> _withBusy(Future<void> Function() fn) async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      await fn();
    } catch (e) {
      if (mounted) setState(() => _status = 'Failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportJson() async {
    await _withBusy(() async {
      final json = await LibraryImportExportService.instance.exportJson();
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export library JSON',
        fileName: 'sunfire-library.json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
        bytes: kIsWeb ? Uint8List.fromList(utf8.encode(json)) : null,
      );
      if (!kIsWeb && path != null) {
        await File(path).writeAsString(json);
      }
      if (mounted) {
        setState(() => _status = path == null && !kIsWeb
            ? 'Export cancelled'
            : 'Exported JSON');
      }
    });
  }

  Future<void> _exportCsv() async {
    await _withBusy(() async {
      final csv = await LibraryImportExportService.instance.exportCsv();
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export library CSV',
        fileName: 'sunfire-library.csv',
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        bytes: kIsWeb ? Uint8List.fromList(utf8.encode(csv)) : null,
      );
      if (!kIsWeb && path != null) {
        await File(path).writeAsString(csv);
      }
      if (mounted) {
        setState(() => _status = path == null && !kIsWeb
            ? 'Export cancelled'
            : 'Exported CSV');
      }
    });
  }

  Future<void> _importFile({required bool csv}) async {
    await _withBusy(() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: csv ? const ['csv'] : const ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _status = 'Import cancelled');
        return;
      }
      final file = result.files.first;
      final raw = file.bytes != null
          ? utf8.decode(file.bytes!)
          : (file.path != null ? await File(file.path!).readAsString() : null);
      if (raw == null || raw.isEmpty) {
        setState(() => _status = 'Empty file');
        return;
      }
      final outcome = csv
          ? await LibraryImportExportService.instance.importCsv(raw)
          : await LibraryImportExportService.instance.importJson(raw);
      if (mounted) {
        setState(() {
          _status =
              'Import done — created ${outcome.created}, updated ${outcome.updated}, '
              'tags ${outcome.tagsAssigned}, skipped ${outcome.skipped}';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Import / Export Library'),
            SunfireBadge.local(),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Export titles, sources, URLs, genres, tags, and progress summaries. '
            'For full Tachiyomi backups use Settings → Backup → Import .tachibk.',
          ),
          const SizedBox(height: 16),
          SunfireButton.primary(
            label: 'Export JSON',
            icon: Icons.upload_file_outlined,
            onPressed: _busy ? null : () => unawaited(_exportJson()),
            expanded: true,
          ),
          const SizedBox(height: 8),
          SunfireButton.secondary(
            label: 'Export CSV',
            icon: Icons.table_chart_outlined,
            onPressed: _busy ? null : () => unawaited(_exportCsv()),
            expanded: true,
          ),
          const SizedBox(height: 24),
          SunfireButton.secondary(
            label: 'Import JSON',
            icon: Icons.download_outlined,
            onPressed: _busy ? null : () => unawaited(_importFile(csv: false)),
            expanded: true,
          ),
          const SizedBox(height: 8),
          SunfireButton.secondary(
            label: 'Import CSV',
            icon: Icons.download_outlined,
            onPressed: _busy ? null : () => unawaited(_importFile(csv: true)),
            expanded: true,
          ),
          if (_busy) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_status != null) ...[
            const SizedBox(height: 16),
            Text(_status!),
          ],
        ],
      ),
    );
  }
}
