import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/backup/tachibk_import_service.dart';
import '../../core/backup/tachibk_parser.dart';
import '../../core/logging/logger_service.dart';
import 'widgets/settings_subpage_scaffold.dart';

/// Client-side `.tachibk` restore: pick a backup file on the device, review
/// what will be imported, then apply it to the Suwayomi server via GraphQL.
class ImportTachibkScreen extends StatefulWidget {
  const ImportTachibkScreen({super.key});

  @override
  State<ImportTachibkScreen> createState() => _ImportTachibkScreenState();
}

class _ImportTachibkScreenState extends State<ImportTachibkScreen> {
  bool _parsing = false;
  bool _applying = false;
  String? _fileName;
  String? _parseError;
  TachiBkImportPlan? _plan;
  bool _applied = false;

  Future<void> _pickAndParse() async {
    setState(() {
      _parsing = true;
      _parseError = null;
      _plan = null;
      _applied = false;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['tachibk', 'zip'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _parsing = false);
        return;
      }
      final file = result.files.single;
      final Uint8List bytes;
      try {
        bytes = file.bytes ?? (await file.xFile.readAsBytes());
      } catch (e) {
        if (mounted) {
          setState(() {
            _parsing = false;
            _parseError = 'Could not read the selected file: $e';
          });
        }
        return;
      }

      final backup = TachiBkParser.parseBytes(bytes);
      final plan = await TachiBkImportService.instance.planImportFromServer(backup);
      if (plan == null) {
        if (mounted) {
          setState(() {
            _parsing = false;
            _parseError = 'Server is not configured or unreachable — connect to your Suwayomi server first.';
          });
        }
        return;
      }
      if (mounted) {
        setState(() {
          _parsing = false;
          _fileName = file.name;
          _plan = plan;
        });
      }
    } on TachiBkParseException catch (e) {
      if (mounted) {
        setState(() {
          _parsing = false;
          _parseError = e.message;
        });
      }
    } catch (e, st) {
      LoggerService.instance.logError('TachiBk parse failed', exception: e, stackTrace: st, category: 'TachiBkImport');
      if (mounted) {
        setState(() {
          _parsing = false;
          _parseError = 'Unexpected error while parsing the backup: $e';
        });
      }
    }
  }

  Future<void> _applyImport() async {
    final plan = _plan;
    if (plan == null || _applying) return;
    setState(() => _applying = true);

    final result = await TachiBkImportService.instance.applyPlan(plan);
    if (!mounted) return;
    setState(() {
      _applying = false;
      _applied = true;
    });

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Restore ${result.imported > 0 ? 'complete' : 'finished'}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Imported: ${result.imported}   Failed: ${result.failed}'),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    result.messages.join('\n'),
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return SettingsSubpageScaffold(
      title: 'Restore .tachibk File',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Fully client-side restore: pick a Tachiyomi/Suwayomi .tachibk backup, review the '
            'manga it contains, and add them to your server library. Sources are matched by '
            'name and language against the sources installed on your server.',
            style: const TextStyle(fontSize: 13, color: Colors.white60),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: (_parsing || _applying) ? null : _pickAndParse,
            icon: const Icon(Icons.folder_open_rounded),
            label: Text(_fileName == null ? 'Choose .tachibk file' : 'Choose another file'),
          ),
          if (_parsing) const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
          if (_parseError != null) Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              _parseError!,
              style: const TextStyle(fontSize: 13, color: Color(0xFFFF8A80)),
            ),
          ),
          if (_fileName != null && _plan != null) ...[
            const SizedBox(height: 12),
            Text(
              '$_fileName — ${_plan!.readyEntries.length} importable, '
              '${_plan!.skippedEntries.length} skipped (missing source)',
              style: TextStyle(fontSize: 13, color: primaryColor),
            ),
            const SizedBox(height: 8),
            ..._plan!.entries.map(_buildEntryTile),
            if (_plan!.categoriesToCreate.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Categories that will be created: ${_plan!.categoriesToCreate.join(', ')}',
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: (_applying || !_plan!.readyEntries.any((e) => e.include)) ? null : _applyImport,
              icon: const Icon(Icons.settings_backup_restore_rounded),
              label: Text(_applying ? 'Restoring…' : 'Import ${_plan!.readyEntries.length} manga'),
            ),
            if (_applied) const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Restore finished. Back out to refresh your library.',
                style: TextStyle(fontSize: 12, color: Colors.greenAccent),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEntryTile(TachiBkImportPlanEntry entry) {
    final ready = entry.status == TachiBkPlanEntryStatus.ready;
    return CheckboxListTile(
      dense: true,
      value: entry.include,
      onChanged: !ready || _applying
          ? null
          : (v) => setState(() => entry.include = v ?? false),
      title: Text(
        entry.manga.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        ready ? '${entry.matchedSource!.name} (${entry.matchedSource!.lang})' : 'Source not installed on server',
        style: TextStyle(
          fontSize: 11.5,
          color: ready ? Colors.white54 : const Color(0xFFFF8A80),
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      secondary: ready
          ? const Icon(Icons.check_circle_outline, size: 18, color: Colors.greenAccent)
          : const Icon(Icons.error_outline, size: 18, color: Color(0xFFFF8A80)),
    );
  }
}