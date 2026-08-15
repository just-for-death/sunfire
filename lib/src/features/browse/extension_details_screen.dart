import 'package:flutter/material.dart';
import 'source_configuration_screen.dart';

class ExtensionDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> extensionData;

  const ExtensionDetailsScreen({
    super.key,
    required this.extensionData,
  });

  @override
  State<ExtensionDetailsScreen> createState() => _ExtensionDetailsScreenState();
}

class _ExtensionDetailsScreenState extends State<ExtensionDetailsScreen> {
  bool _isSourceEnabled = true;

  @override
  Widget build(BuildContext context) {
    final name = widget.extensionData['name'] as String? ?? 'Extension';
    final lang = (widget.extensionData['lang'] as String? ?? 'en').toUpperCase();
    final version = widget.extensionData['version'] as String? ?? '1.4.44';
    final pkgName = widget.extensionData['id'] as String? ?? 'en.readcomiconline';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extension info'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 120.0),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFC2185B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(Icons.pets_rounded, color: Colors.white, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              pkgName,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'https://github.com/keiyoushi/extensions/raw/repo/index.pb',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(version, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  const Text('Version', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Container(width: 1, height: 28, color: const Color(0x2BFFFFFF)),
              Column(
                children: [
                  Text(lang, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  const Text('Language', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0x4DFFFFFF), width: 1),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('UNINSTALL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),

          const SizedBox(height: 28),

          Material(
            color: const Color(0x1F2A2A32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
            ),
            child: ListTile(
              title: const Text('English', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.grey),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SourceConfigurationScreen(sourceName: name),
                        ),
                      );
                    },
                  ),
                  Switch(
                    value: _isSourceEnabled,
                    onChanged: (val) => setState(() => _isSourceEnabled = val),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
