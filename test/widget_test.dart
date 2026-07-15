import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brew_companion/services/store.dart';
import 'package:brew_companion/models/brew.dart';
import 'package:brew_companion/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('boots to the ratio calculator with a computed water weight',
      (tester) async {
    final store = BrewStore();
    await store.load();
    await tester.pumpWidget(BrewApp(store: store));
    await tester.pumpAndSettle();

    // Bottom navigation tabs are present.
    expect(find.text('Ratio'), findsWidgets);
    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('Log'), findsOneWidget);

    // 18 g dose × 1:15 default → 270 ml water shown on the result panel.
    expect(find.text('270 ml'), findsOneWidget);
  });

  test('ratio math and JSON round-trip are stable', () async {
    SharedPreferences.setMockInitialValues({});
    final store = BrewStore();
    await store.load();

    final log = BrewLog(
      id: 'test-1',
      dateEpoch: 1700000000000,
      method: 'Pour Over',
      bean: 'Coorg Arabica',
      roast: 'Medium',
      grind: 'medium-fine',
      dose: 18,
      yieldMl: 270,
      rating: 4,
      flavors: const ['Chocolate', 'Nutty'],
      notes: 'balanced',
    );
    expect(log.ratioText, '1:15.0');

    await store.upsert(log);
    expect(store.count, 1);

    // Reload from the same mock backing store: persistence survives.
    final store2 = BrewStore();
    await store2.load();
    expect(store2.count, 1);
    expect(store2.byId('test-1')?.bean, 'Coorg Arabica');
    expect(store2.byId('test-1')?.flavors, ['Chocolate', 'Nutty']);
  });
}
