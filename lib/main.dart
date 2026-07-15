import 'package:flutter/material.dart';
import 'theme.dart';
import 'services/store.dart';
import 'screens/calculator_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/log_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = BrewStore();
  await store.load();
  runApp(BrewApp(store: store));
}

class BrewApp extends StatelessWidget {
  final BrewStore store;
  const BrewApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreScope(
      store: store,
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          return MaterialApp(
            title: 'Filter Coffee Brew Companion',
            debugShowCheckedModeBanner: false,
            theme: BrewTheme.light(),
            darkTheme: BrewTheme.dark(),
            themeMode: store.themeMode,
            home: const RootShell(),
          );
        },
      ),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _pages = const [
    CalculatorScreen(),
    TimerScreen(),
    LogScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'Ratio',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Log',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
