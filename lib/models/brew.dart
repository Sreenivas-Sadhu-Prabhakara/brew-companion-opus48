/// A single phase in a guided brew (label + duration in seconds).
class BrewStage {
  final String label;
  final String hint;
  final int seconds;
  const BrewStage(this.label, this.hint, this.seconds);
}

/// A brew method preset: default strength ratio + a guided timer recipe.
class BrewMethod {
  final String name;
  final String tagline;
  final double defaultRatio; // water : coffee, e.g. 15 means 1:15
  final List<BrewStage> stages;
  const BrewMethod({
    required this.name,
    required this.tagline,
    required this.defaultRatio,
    required this.stages,
  });

  int get totalSeconds => stages.fold(0, (a, s) => a + s.seconds);

  static const List<BrewMethod> presets = [
    BrewMethod(
      name: 'South Indian Filter',
      tagline: 'Decoction drip · davara–tumbler',
      defaultRatio: 8, // strong decoction, cut with hot milk later
      stages: [
        BrewStage('Load powder', 'Spoon coffee+chicory into the upper chamber, level it', 20),
        BrewStage('Press disc', 'Seat the pressing disc gently — do not compact', 15),
        BrewStage('First pour', 'Pour just-off-boil water to cover the grounds', 25),
        BrewStage('Bloom', 'Let it swell and settle', 40),
        BrewStage('Top up', 'Fill the upper chamber to the brim', 20),
        BrewStage('Slow drip', 'Cover and let the decoction drip through', 600),
      ],
    ),
    BrewMethod(
      name: 'Pour Over',
      tagline: 'V60 · single cup',
      defaultRatio: 15,
      stages: [
        BrewStage('Rinse filter', 'Wet the paper, discard the water', 20),
        BrewStage('Bloom', 'Pour 2× the coffee weight, swirl, wait', 40),
        BrewStage('Pour 1', 'Pour to 60% in slow circles', 45),
        BrewStage('Pour 2', 'Pour to full weight', 40),
        BrewStage('Drawdown', 'Let the bed drain fully', 45),
      ],
    ),
    BrewMethod(
      name: 'French Press',
      tagline: 'Full immersion',
      defaultRatio: 16,
      stages: [
        BrewStage('Add coffee', 'Coarse grounds into the carafe', 15),
        BrewStage('Pour', 'Fill with just-off-boil water', 20),
        BrewStage('Steep', 'Cap the plunger, do not press', 240),
        BrewStage('Break crust', 'Skim and stir the top', 20),
        BrewStage('Plunge', 'Press slowly and decant', 20),
      ],
    ),
    BrewMethod(
      name: 'Moka Pot',
      tagline: 'Stovetop',
      defaultRatio: 10,
      stages: [
        BrewStage('Fill base', 'Hot water to the valve line', 20),
        BrewStage('Fill basket', 'Level the grounds, no tamp', 20),
        BrewStage('Heat', 'Medium flame, lid open', 180),
        BrewStage('Gurgle', 'Pull off at the first sputter', 25),
      ],
    ),
  ];

  static BrewMethod byName(String name) =>
      presets.firstWhere((m) => m.name == name, orElse: () => presets.first);
}

/// A saved brew with its recipe and tasting notes.
class BrewLog {
  final String id;
  final int dateEpoch;
  final String method;
  final String bean;
  final String roast;
  final String grind;
  final double dose; // grams of coffee
  final double yieldMl; // grams/ml of water or beverage
  final int rating; // 0..5
  final List<String> flavors;
  final String notes;

  BrewLog({
    required this.id,
    required this.dateEpoch,
    required this.method,
    required this.bean,
    required this.roast,
    required this.grind,
    required this.dose,
    required this.yieldMl,
    required this.rating,
    required this.flavors,
    required this.notes,
  });

  double get ratio => dose > 0 ? yieldMl / dose : 0;
  String get ratioText => dose > 0 ? '1:${ratio.toStringAsFixed(1)}' : '—';
  DateTime get date => DateTime.fromMillisecondsSinceEpoch(dateEpoch);

  BrewLog copyWith({
    String? method,
    String? bean,
    String? roast,
    String? grind,
    double? dose,
    double? yieldMl,
    int? rating,
    List<String>? flavors,
    String? notes,
  }) {
    return BrewLog(
      id: id,
      dateEpoch: dateEpoch,
      method: method ?? this.method,
      bean: bean ?? this.bean,
      roast: roast ?? this.roast,
      grind: grind ?? this.grind,
      dose: dose ?? this.dose,
      yieldMl: yieldMl ?? this.yieldMl,
      rating: rating ?? this.rating,
      flavors: flavors ?? this.flavors,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': dateEpoch,
        'method': method,
        'bean': bean,
        'roast': roast,
        'grind': grind,
        'dose': dose,
        'yield': yieldMl,
        'rating': rating,
        'flavors': flavors,
        'notes': notes,
      };

  factory BrewLog.fromJson(Map<String, dynamic> j) => BrewLog(
        id: j['id'] as String,
        dateEpoch: j['date'] as int,
        method: j['method'] as String? ?? 'Pour Over',
        bean: j['bean'] as String? ?? '',
        roast: j['roast'] as String? ?? 'Medium',
        grind: j['grind'] as String? ?? '',
        dose: (j['dose'] as num?)?.toDouble() ?? 0,
        yieldMl: (j['yield'] as num?)?.toDouble() ?? 0,
        rating: (j['rating'] as num?)?.toInt() ?? 0,
        flavors: (j['flavors'] as List?)?.map((e) => e.toString()).toList() ?? [],
        notes: j['notes'] as String? ?? '',
      );

  static const roasts = ['Light', 'Medium-Light', 'Medium', 'Medium-Dark', 'Dark'];
  static const flavorPalette = [
    'Chocolate', 'Caramel', 'Nutty', 'Malty', 'Floral', 'Citrus',
    'Berry', 'Stone fruit', 'Spicy', 'Earthy', 'Smoky', 'Bright',
  ];
}
