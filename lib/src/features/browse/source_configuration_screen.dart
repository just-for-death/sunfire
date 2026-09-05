import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/engine/quickjs_service.dart';
import '../../core/services/image_cache_helper.dart';

class SourceConfigurationScreen extends StatefulWidget {
  final String sourceName;

  const SourceConfigurationScreen({
    super.key,
    required this.sourceName,
  });

  @override
  State<SourceConfigurationScreen> createState() => _SourceConfigurationScreenState();
}

class _SourceConfigurationScreenState extends State<SourceConfigurationScreen> {
  String _customBaseUrl = '';
  String _imageQuality = 'Original';
  String _networkMode = 'Auto (Direct with FlareSolverr)';
  bool _isLoading = true;

  String? _defaultBaseUrl;
  String _installedVersion = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final sourceKey = widget.sourceName.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

    _defaultBaseUrl = QuickJsService.instance.getSourceBaseUrl(widget.sourceName);
    _installedVersion = QuickJsService.instance.getInstalledVersion(widget.sourceName);

    setState(() {
      _customBaseUrl = prefs.getString('pref_source_${sourceKey}_base_url') ?? _defaultBaseUrl ?? '';
      _imageQuality = prefs.getString('pref_source_${sourceKey}_quality') ?? 'Original';
      _networkMode = prefs.getString('pref_source_${sourceKey}_network_mode') ?? 'Auto (Direct with FlareSolverr)';
      _isLoading = false;
    });
  }

  Future<void> _savePreference(String keySuffix, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final sourceKey = widget.sourceName.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    await prefs.setString('pref_source_${sourceKey}_$keySuffix', value);
  }

  void _showSelectionDialog({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final isSelected = opt == currentValue;
              return ListTile(
                title: Text(
                  opt,
                  style: TextStyle(
                    color: isSelected ? primaryColor : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected ? Icon(Icons.check_circle_rounded, color: primaryColor) : null,
                onTap: () {
                  onSelected(opt);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showEditBaseUrlDialog() {
    final controller = TextEditingController(text: _customBaseUrl);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Custom Source Mirror', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Override the default endpoint with a community mirror or proxy if blocked in your region.',
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: _defaultBaseUrl ?? 'https://...',
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            if (_defaultBaseUrl != null && _defaultBaseUrl!.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() => _customBaseUrl = _defaultBaseUrl!);
                  _savePreference('base_url', _defaultBaseUrl!);
                  Navigator.pop(context);
                },
                child: const Text('Reset Default'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final trimmed = controller.text.trim();
                setState(() => _customBaseUrl = trimmed);
                _savePreference('base_url', trimmed);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.sourceName} Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.sourceName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    if (_installedVersion.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'v$_installedVersion',
                          style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                if (_defaultBaseUrl != null && _defaultBaseUrl!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Default URL: $_defaultBaseUrl',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text('Source Mirror / Base URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(
              _customBaseUrl.isNotEmpty ? _customBaseUrl : (_defaultBaseUrl ?? 'Default'),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            trailing: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
            onTap: _showEditBaseUrlDialog,
          ),
          const Divider(color: Colors.white10),
          ListTile(
            title: const Text('Image Quality', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(_imageQuality, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            onTap: () {
              _showSelectionDialog(
                title: 'Image Quality',
                options: ['Original', 'High Compression', 'Data Saver'],
                currentValue: _imageQuality,
                onSelected: (val) {
                  setState(() => _imageQuality = val);
                  _savePreference('quality', val);
                },
              );
            },
          ),
          const Divider(color: Colors.white10),
          ListTile(
            title: const Text('Network Bypass Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(_networkMode, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            onTap: () {
              _showSelectionDialog(
                title: 'Network Bypass Mode',
                options: [
                  'Auto (Direct with FlareSolverr)',
                  'Direct Only (No Bypass)',
                  'Server Proxy Preferred',
                ],
                currentValue: _networkMode,
                onSelected: (val) {
                  setState(() => _networkMode = val);
                  _savePreference('network_mode', val);
                },
              );
            },
          ),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent, width: 1),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            label: const Text(
              'CLEAR SOURCE IMAGE CACHE',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            onPressed: () async {
              await ImageCacheHelper.clearCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Image cache cleared for ${widget.sourceName}')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
