import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/brew.dart';
import '../services/store.dart';
import '../widgets/common.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late BrewMethod _method;
  bool _init = false;

  Timer? _ticker;
  bool _running = false;
  int _stage = 0;
  double _remaining = 0; // seconds left in current stage
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _method = BrewMethod.byName(StoreScope.of(context).defaultMethod);
      _remaining = _method.stages.first.seconds.toDouble();
      _init = true;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _selectMethod(BrewMethod m) {
    _ticker?.cancel();
    setState(() {
      _method = m;
      _running = false;
      _done = false;
      _stage = 0;
      _remaining = m.stages.first.seconds.toDouble();
    });
  }

  void _toggle() {
    if (_done) {
      _reset();
      return;
    }
    if (_running) {
      _ticker?.cancel();
      setState(() => _running = false);
    } else {
      HapticFeedback.selectionClick();
      setState(() => _running = true);
      _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
    }
  }

  void _tick() {
    setState(() {
      _remaining -= 0.2;
      if (_remaining <= 0) {
        if (_stage < _method.stages.length - 1) {
          _stage++;
          _remaining = _method.stages[_stage].seconds.toDouble();
          HapticFeedback.mediumImpact();
        } else {
          _running = false;
          _done = true;
          _remaining = 0;
          _ticker?.cancel();
          HapticFeedback.heavyImpact();
        }
      }
    });
  }

  void _skip() {
    if (_done) return;
    setState(() {
      if (_stage < _method.stages.length - 1) {
        _stage++;
        _remaining = _method.stages[_stage].seconds.toDouble();
        HapticFeedback.selectionClick();
      } else {
        _remaining = 0;
        _running = false;
        _done = true;
        _ticker?.cancel();
      }
    });
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _running = false;
      _done = false;
      _stage = 0;
      _remaining = _method.stages.first.seconds.toDouble();
    });
  }

  String _fmt(double s) {
    final t = s.ceil();
    final m = (t ~/ 60).toString().padLeft(2, '0');
    final sec = (t % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stage = _method.stages[_stage];
    final stageTotal = stage.seconds.toDouble();
    final progress = stageTotal > 0 ? (1 - _remaining / stageTotal).clamp(0.0, 1.0) : 1.0;
    final next = _stage < _method.stages.length - 1 ? _method.stages[_stage + 1] : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Brew Timer')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
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
                  onTap: () => _selectMethod(m),
                );
              },
            ),
          ),
          const SizedBox(height: 28),

          // Countdown ring
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: _done ? 1 : progress,
                      strokeWidth: 12,
                      strokeCap: StrokeCap.round,
                      backgroundColor: scheme.outlineVariant.withValues(alpha: 0.4),
                      color: _done ? scheme.tertiary : scheme.secondary,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _done ? 'Done' : 'Stage ${_stage + 1}/${_method.stages.length}',
                        style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _done ? '☕' : _fmt(_remaining),
                        style: TextStyle(
                          fontSize: _done ? 56 : 54,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_done ? 'Brew complete' : stage.label,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  _done
                      ? 'Pour, taste, and log it while it is fresh.'
                      : stage.hint,
                  style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
                ),
                if (next != null && !_done) ...[
                  const Divider(height: 26),
                  Row(
                    children: [
                      Icon(Icons.arrow_forward_rounded,
                          size: 18, color: scheme.secondary),
                      const SizedBox(width: 8),
                      Text('Next · ${next.label}  (${_fmt(next.seconds.toDouble())})',
                          style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _toggle,
                  icon: Icon(_done
                      ? Icons.replay
                      : _running
                          ? Icons.pause
                          : Icons.play_arrow),
                  label: Text(_done
                      ? 'Reset'
                      : _running
                          ? 'Pause'
                          : 'Start'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _done ? null : _skip,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text('Total recipe ${_fmt(_method.totalSeconds.toDouble())}',
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
