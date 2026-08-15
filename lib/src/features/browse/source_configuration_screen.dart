import 'package:flutter/material.dart';

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
  String _preferredMirror = 'readcomiconline.li';
  String _imageQuality = 'Original';
  String _serverPreference = 'Default Direct (FlareSolverr Auto)';

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
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final isSelected = opt == currentValue;
              return ListTile(
                title: Text(opt, style: TextStyle(color: isSelected ? primaryColor : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Source Configuration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
        children: [
          ListTile(
            title: const Text('Preferred Mirror', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(_preferredMirror, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            onTap: () {
              _showSelectionDialog(
                title: 'Preferred Mirror',
                options: ['readcomiconline.li', 'readcomiconline.to', 'readcomiconline.io'],
                currentValue: _preferredMirror,
                onSelected: (val) => setState(() => _preferredMirror = val),
              );
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Image Quality Selector', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(_imageQuality, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            onTap: () {
              _showSelectionDialog(
                title: 'Image Quality',
                options: ['Original', 'High Compression', 'Low Bandwidth'],
                currentValue: _imageQuality,
                onSelected: (val) => setState(() => _imageQuality = val),
              );
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Server Preference', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text(_serverPreference, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            onTap: () {
              _showSelectionDialog(
                title: 'Server Preference',
                options: ['Default Direct (FlareSolverr Auto)', 'Proxy Server 1', 'CDN Fallback'],
                currentValue: _serverPreference,
                onSelected: (val) => setState(() => _serverPreference = val),
              );
            },
          ),
        ],
      ),
    );
  }
}
