import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _urlController;
  String? _pingResult;
  bool _pinging = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ref.read(serviceUrlProvider));
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testAndSave() async {
    await ref.read(serviceUrlProvider.notifier).set(_urlController.text);
    setState(() {
      _pinging = true;
      _pingResult = null;
    });
    final client = ref.read(enrichmentClientProvider);
    final ok = client != null && await client.ping();
    if (!mounted) return;
    setState(() {
      _pinging = false;
      _pingResult = ok ? 'Connected ✓' : 'Unreachable ✗';
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentWeight = ref.watch(contentWeightProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Enrichment service',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Your PC running the Python service on the same Wi-Fi.',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'Service URL',
              hintText: 'http://192.168.0.100:8973',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                onPressed: _pinging ? null : _testAndSave,
                icon: _pinging
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_tethering),
                label: const Text('Test & save'),
              ),
              const SizedBox(width: 16),
              if (_pingResult != null)
                Text(
                  _pingResult!,
                  style: TextStyle(
                    color: _pingResult!.contains('✓')
                        ? Colors.greenAccent
                        : scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const Divider(height: 40),
          Text('Recommender', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Blend: ${(contentWeight * 100).round()}% content / '
              '${((1 - contentWeight) * 100).round()}% history'),
          Slider(
            value: contentWeight,
            onChanged: (v) => ref.read(contentWeightProvider.notifier).set(v),
          ),
          Text(
            'History weighting applies once the ALS model is trained '
            '(deliverable 7). Until then, recommendations are pure content.',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
