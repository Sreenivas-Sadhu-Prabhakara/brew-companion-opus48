import 'package:flutter/material.dart';
import '../models/brew.dart';
import '../services/store.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          const SectionLabel('Brew defaults'),
          Panel(
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(child: Text('Default method')),
                    DropdownButton<String>(
                      value: store.defaultMethod,
                      underline: const SizedBox.shrink(),
                      items: BrewMethod.presets
                          .map((m) =>
                              DropdownMenuItem(value: m.name, child: Text(m.name)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) store.setDefaultMethod(v);
                      },
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Expanded(child: Text('Default strength')),
                    Text('1:${store.defaultRatio.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: scheme.secondary)),
                  ],
                ),
                Slider(
                  value: store.defaultRatio,
                  min: 6,
                  max: 18,
                  divisions: 24,
                  label: '1:${store.defaultRatio.toStringAsFixed(1)}',
                  onChanged: (v) => store.setDefaultRatio(v),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Expanded(child: Text('Cup size')),
                    Text('${store.cupMl.toStringAsFixed(0)} ml',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: scheme.secondary)),
                  ],
                ),
                Slider(
                  value: store.cupMl,
                  min: 60,
                  max: 250,
                  divisions: 19,
                  label: '${store.cupMl.toStringAsFixed(0)} ml',
                  onChanged: (v) => store.setCupMl(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const SectionLabel('Appearance'),
          SegmentedButton<ThemeMode>(
            segments: ThemeMode.values
                .map((m) => ButtonSegment(value: m, label: Text(_themeLabel(m))))
                .toList(),
            selected: {store.themeMode},
            showSelectedIcon: false,
            onSelectionChanged: (s) => store.setThemeMode(s.first),
          ),
          const SizedBox(height: 22),

          const SectionLabel('Data'),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.offline_bolt_outlined, color: scheme.tertiary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Everything is stored on this device. No account, no network.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: store.count == 0
                      ? null
                      : () => _confirmClear(context, store),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: scheme.error,
                    side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: Text('Clear all ${store.count} brews'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),

          Center(
            child: Column(
              children: [
                Text('Filter Coffee Brew Companion',
                    style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('v1.0.0 · offline-first',
                    style: TextStyle(
                        color: scheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode m) => switch (m) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  Future<void> _confirmClear(BuildContext context, BrewStore store) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all brews?'),
        content: const Text('Every logged brew and tasting note will be deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true) await store.clearAll();
  }
}
