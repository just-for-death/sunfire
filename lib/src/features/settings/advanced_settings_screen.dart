import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/logging/logger_service.dart';

class AdvancedSettingsScreen extends StatefulWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  State<AdvancedSettingsScreen> createState() => _AdvancedSettingsScreenState();
}

class _AdvancedSettingsScreenState extends State<AdvancedSettingsScreen> {
  void _showLogsModal() async {
    final logs = await LoggerService.instance.getDiagnosticLogs();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1F1F24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Diagnostic Logs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      logs.isEmpty ? 'No diagnostic logs recorded.' : logs,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.greenAccent),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced & Diagnostics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 120.0),
        children: [
          Text('SYSTEM DIAGNOSTICS', style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Material(
            color: const Color(0x1F2A2A32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0x2BFFFFFF), width: 0.8),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.bug_report_rounded, color: primaryColor),
                  title: const Text('View Diagnostic Logs', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Inspect local sunfire_diagnostic.log file'),
                  onTap: _showLogsModal,
                ),
                ListTile(
                  leading: Icon(Icons.cleaning_services_rounded, color: primaryColor),
                  title: const Text('Clear Diagnostic Logs', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Truncate sunfire_diagnostic.log log file'),
                  onTap: () async {
                    await LoggerService.instance.clearLogs();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Diagnostic log file cleared.')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
