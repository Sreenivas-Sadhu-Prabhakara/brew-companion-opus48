import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/brew.dart';

/// Single source of truth. Holds settings + the brew log, persisted to
/// shared_preferences as JSON. Offline-first: nothing leaves the device.
class BrewStore extends ChangeNotifier {
  static const _kLogs = 'brew_logs_v1';
  static const _kMethod = 'default_method';
  static const _kRatio = 'default_ratio';
  static const _kCup = 'cup_ml';
  static const _kTheme = 'theme_mode';

  SharedPreferences? _prefs;

  List<BrewLog> _logs = [];
  List<BrewLog> get logs => List.unmodifiable(_logs);

  String defaultMethod = 'Pour Over';
  double defaultRatio = 15;
  double cupMl = 120;
  ThemeMode themeMode = ThemeMode.system;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    defaultMethod = p.getString(_kMethod) ?? defaultMethod;
    defaultRatio = p.getDouble(_kRatio) ?? defaultRatio;
    cupMl = p.getDouble(_kCup) ?? cupMl;
    themeMode = ThemeMode.values[(p.getInt(_kTheme) ?? 0).clamp(0, 2)];
    final raw = p.getString(_kLogs);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        _logs = list
            .map((e) => BrewLog.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.dateEpoch.compareTo(a.dateEpoch));
      } catch (_) {
        _logs = [];
      }
    }
    notifyListeners();
  }

  Future<void> _persistLogs() async {
    await _prefs?.setString(
      _kLogs,
      jsonEncode(_logs.map((e) => e.toJson()).toList()),
    );
  }

  BrewLog? byId(String id) {
    for (final l in _logs) {
      if (l.id == id) return l;
    }
    return null;
  }

  Future<void> upsert(BrewLog log) async {
    final i = _logs.indexWhere((e) => e.id == log.id);
    if (i >= 0) {
      _logs[i] = log;
    } else {
      _logs.insert(0, log);
    }
    _logs.sort((a, b) => b.dateEpoch.compareTo(a.dateEpoch));
    await _persistLogs();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _logs.removeWhere((e) => e.id == id);
    await _persistLogs();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _logs = [];
    await _persistLogs();
    notifyListeners();
  }

  // ---- Derived stats for the log header ----
  int get count => _logs.length;
  double get avgRating {
    final rated = _logs.where((l) => l.rating > 0).toList();
    if (rated.isEmpty) return 0;
    return rated.fold(0, (a, l) => a + l.rating) / rated.length;
  }

  String? get topMethod {
    if (_logs.isEmpty) return null;
    final counts = <String, int>{};
    for (final l in _logs) {
      counts[l.method] = (counts[l.method] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  // ---- Settings mutators ----
  Future<void> setDefaultMethod(String v) async {
    defaultMethod = v;
    await _prefs?.setString(_kMethod, v);
    notifyListeners();
  }

  Future<void> setDefaultRatio(double v) async {
    defaultRatio = v;
    await _prefs?.setDouble(_kRatio, v);
    notifyListeners();
  }

  Future<void> setCupMl(double v) async {
    cupMl = v;
    await _prefs?.setDouble(_kCup, v);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode m) async {
    themeMode = m;
    await _prefs?.setInt(_kTheme, m.index);
    notifyListeners();
  }
}

/// Lightweight InheritedNotifier so any screen can read the store and rebuild.
class StoreScope extends InheritedNotifier<BrewStore> {
  const StoreScope({super.key, required BrewStore store, required super.child})
      : super(notifier: store);

  static BrewStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StoreScope>();
    assert(scope != null, 'StoreScope missing above this widget');
    return scope!.notifier!;
  }
}
