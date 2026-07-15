import 'package:flutter/material.dart';
import '../models/brew.dart';
import '../services/store.dart';
import '../widgets/common.dart';
import 'log_edit_screen.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  void _openEditor(BuildContext context, {BrewLog? existing}) {
    final draft = existing ??
        BrewLog(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          dateEpoch: DateTime.now().millisecondsSinceEpoch,
          method: StoreScope.of(context).defaultMethod,
          bean: '',
          roast: 'Medium',
          grind: '',
          dose: 18,
          yieldMl: 270,
          rating: 0,
          flavors: const [],
          notes: '',
        );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LogEditScreen(draft: draft, isNew: existing == null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final logs = store.logs;

    return Scaffold(
      appBar: AppBar(title: const Text('Brew Log')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('New brew'),
      ),
      body: logs.isEmpty
          ? _EmptyState(onAdd: () => _openEditor(context))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              children: [
                Row(
                  children: [
                    StatPill(
                        icon: Icons.local_cafe,
                        value: '${store.count}',
                        caption: 'brews'),
                    const SizedBox(width: 10),
                    StatPill(
                        icon: Icons.star_rounded,
                        value: store.avgRating > 0
                            ? store.avgRating.toStringAsFixed(1)
                            : '—',
                        caption: 'avg rating'),
                    const SizedBox(width: 10),
                    StatPill(
                        icon: Icons.favorite_rounded,
                        value: store.topMethod ?? '—',
                        caption: 'top method'),
                  ],
                ),
                const SizedBox(height: 20),
                const SectionLabel('History'),
                ...logs.map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BrewCard(
                        log: l,
                        dateLabel:
                            '${l.date.day} ${_months[l.date.month - 1]}',
                        onTap: () => _openEditor(context, existing: l),
                      ),
                    )),
              ],
            ),
    );
  }
}

class _BrewCard extends StatelessWidget {
  final BrewLog log;
  final String dateLabel;
  final VoidCallback onTap;
  const _BrewCard({required this.log, required this.dateLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.bean.isEmpty ? log.method : log.bean,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        '${log.method} · ${log.roast} · ${log.ratioText}',
                        style: TextStyle(
                            color: scheme.onSurfaceVariant, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(dateLabel,
                    style: TextStyle(
                        color: scheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                StarRating(value: log.rating, size: 20),
                const Spacer(),
                if (log.flavors.isNotEmpty)
                  Flexible(
                    child: Text(
                      log.flavors.take(3).join(' · '),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: scheme.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.coffee_maker_outlined,
                size: 72, color: scheme.secondary.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text('No brews yet',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Dial in a ratio, run the timer, then save your first brew with tasting notes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Log a brew'),
            ),
          ],
        ),
      ),
    );
  }
}
