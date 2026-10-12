// lib/src/features/reader/listen_sheet.dart
//
// R9.3/R9.4: Listen sheet - OCR transcript of the current page with
// text-to-speech playback and per-block highlights.

library;

import 'dart:async';

import 'package:flutter/material.dart';

import 'controller/ocr_service.dart';
import 'controller/tts_service.dart';

/// Bottom sheet: OCR transcript + TTS playback for one page.
class ListenSheet extends StatefulWidget {
  const ListenSheet({
    super.key,
    required this.pageUrl,
    required this.headers,
    required this.title,
  });

  final String pageUrl;
  final Map<String, String> headers;
  final String title;

  /// Show the sheet.
  static Future<void> show(
    BuildContext context, {
    required String pageUrl,
    required Map<String, String> headers,
    required String title,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ListenSheet(
          pageUrl: pageUrl,
          headers: headers,
          title: title,
        ),
      ),
    );
  }

  @override
  State<ListenSheet> createState() => _ListenSheetState();
}

class _ListenSheetState extends State<ListenSheet> {
  OcrPageResult? _result;
  String? _error;
  bool _speaking = false;
  bool _cancelled = false;
  int _activeBlock = -1;

  @override
  void initState() {
    super.initState();
    unawaited(_runOcr());
  }

  @override
  void dispose() {
    _cancelled = true;
    unawaited(TtsService.instance.stop());
    super.dispose();
  }

  Future<void> _runOcr() async {
    final result = await OcrService.instance.recognizeUrl(
      widget.pageUrl,
      headers: widget.headers,
    );
    if (!mounted) return;
    setState(() {
      _result = result;
      if (result.isEmpty) _error = 'No text found on this page.';
    });
  }

  Future<void> _toggleSpeak() async {
    if (_speaking) {
      _cancelled = true;
      await TtsService.instance.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    final blocks = _result?.blocks ?? [];
    if (blocks.isEmpty) return;
    _cancelled = false;
    setState(() {
      _speaking = true;
      _activeBlock = -1;
    });
    final language =
        TtsService.languageForScript(_result!.script.name);
    await TtsService.instance.speakBlocks(
      [for (final b in blocks) b.text],
      language: language,
      onBlock: (i) {
        if (mounted) setState(() => _activeBlock = i);
      },
      cancelled: () => _cancelled,
    );
    if (mounted) {
      setState(() {
        _speaking = false;
        _activeBlock = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Listen',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      Text(widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: (_result == null || _result!.isEmpty)
                      ? null
                      : _toggleSpeak,
                  icon: Icon(_speaking
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded),
                  label: Text(_speaking ? 'Stop' : 'Play'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildBody(cs)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    if (_result == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _result!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.text_fields_rounded,
                size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(_error!,
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: _result!.blocks.length,
      itemBuilder: (context, i) {
        final block = _result!.blocks[i];
        final active = i == _activeBlock;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: active
                ? cs.primaryContainer
                : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: active
                ? Border.all(color: cs.primary, width: 1.5)
                : null,
          ),
          child: Text(
            block.text,
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: active
                  ? cs.onPrimaryContainer
                  : cs.onSurface,
            ),
          ),
        );
      },
    );
  }
}
