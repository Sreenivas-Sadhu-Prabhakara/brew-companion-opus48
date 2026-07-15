import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/brew.dart';
import '../services/store.dart';
import '../widgets/common.dart';
import 'log_edit_screen.dart';

enum SolveMode { fromDose, fromWater }

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  late BrewMethod _method;
  SolveMode _mode = SolveMode.fromDose;
  double _ratio = 15;
  final _doseCtrl = TextEditingController(text: '18');
  final _waterCtrl = TextEditingController(text: '270');
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      final store = StoreScope.of(context);
      _method = BrewMethod.byName(store.defaultMethod);
      _ratio = store.defaultRatio;
      _recompute();
      _init = true;
    }
  }

  @override
  void dispose() {
    _doseCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  double get _dose => double.tryParse(_doseCtrl.text) ?? 0;
  double get _water => double.tryParse(_waterCtrl.text) ?? 0;

  void _recompute() {
    if (_mode == SolveMode.fromDose) {
      _waterCtrl.text = (_dose * _ratio).toStringAsFixed(0);
    } else {
      final d = _ratio > 0 ? _water / _ratio : 0;
      _doseCtrl.text = d.toStringAsFixed(1);
    }
  }

  void _pickMethod(BrewMethod m) {
    setState(() {
      _method = m;
      _ratio = m.defaultRatio;
      _recompute();
    });
  }

  void _fillCups(int cups) {
    final store = StoreScope.of(context);
    setState(() {
      _mode = SolveMode.fromWater;
      _waterCtrl.text = (cups * store.cupMl).toStringAsFixed(0);
      _recompute();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final store = StoreScope.of(context);
    final cups = store.cupMl > 0 ? _water / store.cupMl : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Ratio')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          const SectionLabel('Method'),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: BrewMethod.presets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final m = BrewMethod.presets[i];
                return ChoiceTag(
                  label: m.name,
                  selected: m.name == _method.name,
                  onTap: () => _pickMethod(m),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(_method.tagline,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 22),

          // Big result panel
          Panel(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
            child: Column(
              children: [
                Row(
                  children: [
                    _bigStat('${_dose.toStringAsFixed(_dose % 1 == 0 ? 0 : 1)} g',
                        'Coffee', scheme.primary),
                    Container(width: 1, height: 46, color: scheme.outlineVariant),
                    _bigStat('${_water.toStringAsFixed(0)} ml', 'Water',
                        scheme.tertiary),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '1 : ${_ratio.toStringAsFixed(_ratio % 1 == 0 ? 0 : 1)}   ·   ≈ ${cups.toStringAsFixed(1)} cups',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: scheme.secondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const SectionLabel('Solve for'),
          SegmentedButton<SolveMode>(
            segments: const [
              ButtonSegment(
                  value: SolveMode.fromDose,
                  label: Text('Water from dose'),
                  icon: Icon(Icons.scale_outlined)),
              ButtonSegment(
                  value: SolveMode.fromWater,
                  label: Text('Dose from water'),
                  icon: Icon(Icons.water_drop_outlined)),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() {
              _mode = s.first;
              _recompute();
            }),
          ),
          const SizedBox(height: 18),

          if (_mode == SolveMode.fromDose)
            _numberField('Coffee dose', 'g', _doseCtrl)
          else
            _numberField('Water', 'ml', _waterCtrl),
          const SizedBox(height: 20),

          const SectionLabel('Strength'),
          Row(
            children: [
              Text('1:${_ratio.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Expanded(
                child: Slider(
                  value: _ratio,
                  min: 6,
                  max: 18,
                  divisions: 24,
                  label: '1:${_ratio.toStringAsFixed(1)}',
                  onChanged: (v) => setState(() {
                    _ratio = v;
                    _recompute();
                  }),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Strong', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
              Text('Balanced', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
              Text('Mild', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 22),

          const SectionLabel('Quick cups'),
          Wrap(
            spacing: 8,
            children: [1, 2, 3, 4].map((c) {
              return ChoiceTag(
                label: '$c cup${c > 1 ? 's' : ''}',
                selected: false,
                onTap: () => _fillCups(c),
              );
            }).toList(),
          ),
          const SizedBox(height: 26),

          FilledButton.icon(
            onPressed: _saveAsBrew,
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Save as brew'),
          ),
        ],
      ),
    );
  }

  Widget _bigStat(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _numberField(String label, String suffix, TextEditingController c) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      onChanged: (_) => setState(_recompute),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
      ),
    );
  }

  Future<void> _saveAsBrew() async {
    final draft = BrewLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      dateEpoch: DateTime.now().millisecondsSinceEpoch,
      method: _method.name,
      bean: '',
      roast: 'Medium',
      grind: '',
      dose: _dose,
      yieldMl: _water,
      rating: 0,
      flavors: const [],
      notes: '',
    );
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LogEditScreen(draft: draft, isNew: true)),
    );
  }
}
