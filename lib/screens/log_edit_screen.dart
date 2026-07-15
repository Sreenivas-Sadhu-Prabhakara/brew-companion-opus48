import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/brew.dart';
import '../services/store.dart';
import '../widgets/common.dart';

class LogEditScreen extends StatefulWidget {
  final BrewLog draft;
  final bool isNew;
  const LogEditScreen({super.key, required this.draft, required this.isNew});

  @override
  State<LogEditScreen> createState() => _LogEditScreenState();
}

class _LogEditScreenState extends State<LogEditScreen> {
  late String _method;
  late String _roast;
  late int _rating;
  late List<String> _flavors;
  late final TextEditingController _bean;
  late final TextEditingController _grind;
  late final TextEditingController _dose;
  late final TextEditingController _yield;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _method = d.method;
    _roast = d.roast;
    _rating = d.rating;
    _flavors = List.of(d.flavors);
    _bean = TextEditingController(text: d.bean);
    _grind = TextEditingController(text: d.grind);
    _dose = TextEditingController(text: d.dose > 0 ? _trim(d.dose) : '');
    _yield = TextEditingController(text: d.yieldMl > 0 ? _trim(d.yieldMl) : '');
    _notes = TextEditingController(text: d.notes);
  }

  String _trim(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  void dispose() {
    _bean.dispose();
    _grind.dispose();
    _dose.dispose();
    _yield.dispose();
    _notes.dispose();
    super.dispose();
  }

  double get _ratio {
    final d = double.tryParse(_dose.text) ?? 0;
    final y = double.tryParse(_yield.text) ?? 0;
    return d > 0 ? y / d : 0;
  }

  Future<void> _save() async {
    final store = StoreScope.of(context);
    final log = widget.draft.copyWith(
      method: _method,
      bean: _bean.text.trim(),
      roast: _roast,
      grind: _grind.text.trim(),
      dose: double.tryParse(_dose.text) ?? 0,
      yieldMl: double.tryParse(_yield.text) ?? 0,
      rating: _rating,
      flavors: _flavors,
      notes: _notes.text.trim(),
    );
    await store.upsert(log);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete brew?'),
        content: const Text('This tasting entry will be removed permanently.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true && mounted) {
      await StoreScope.of(context).delete(widget.draft.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? 'New brew' : 'Edit brew'),
        actions: [
          if (!widget.isNew)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          const SectionLabel('Method'),
          DropdownButtonFormField<String>(
            initialValue: _method,
            items: BrewMethod.presets
                .map((m) => DropdownMenuItem(value: m.name, child: Text(m.name)))
                .toList(),
            onChanged: (v) => setState(() => _method = v ?? _method),
          ),
          const SizedBox(height: 18),

          const SectionLabel('Bean'),
          TextField(
            controller: _bean,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Bean / blend',
              hintText: 'e.g. Coorg Arabica + chicory',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _roast,
            decoration: const InputDecoration(labelText: 'Roast'),
            items: BrewLog.roasts
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => _roast = v ?? _roast),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _grind,
            decoration: const InputDecoration(
              labelText: 'Grind',
              hintText: 'e.g. medium-fine, 18 clicks',
            ),
          ),
          const SizedBox(height: 20),

          const SectionLabel('Recipe'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dose,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                      labelText: 'Dose', suffixText: 'g'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _yield,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                      labelText: 'Yield', suffixText: 'ml'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _ratio > 0 ? 'Ratio 1:${_ratio.toStringAsFixed(1)}' : 'Ratio —',
              style: TextStyle(
                  color: scheme.secondary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 20),

          const SectionLabel('Rating'),
          Center(
            child: StarRating(
              value: _rating,
              size: 40,
              onChanged: (v) => setState(() => _rating = v),
            ),
          ),
          const SizedBox(height: 22),

          const SectionLabel('Flavour notes'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BrewLog.flavorPalette.map((f) {
              final sel = _flavors.contains(f);
              return ChoiceTag(
                label: f,
                selected: sel,
                onTap: () => setState(() {
                  sel ? _flavors.remove(f) : _flavors.add(f);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          const SectionLabel('Notes'),
          TextField(
            controller: _notes,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Aroma, body, aftertaste, what to change next time…',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 26),

          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text(widget.isNew ? 'Save brew' : 'Update brew'),
          ),
        ],
      ),
    );
  }
}
