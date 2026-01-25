enum ItemForm { solid, liquid, gas }

class GameItem {
  final String className;
  final String name;
  final String description;
  final String unlockedBy;
  final int stackSize;
  final int energy;
  final double radioactive;
  final bool canBeDiscarded;
  final int sinkPoints;
  final String? abbreviation;
  final ItemForm form;
  final String fluidColor;
  final bool alienItem;

  const GameItem({
    required this.className,
    required this.name,
    required this.description,
    required this.unlockedBy,
    required this.stackSize,
    required this.energy,
    required this.radioactive,
    required this.canBeDiscarded,
    required this.sinkPoints,
    this.abbreviation,
    required this.form,
    required this.fluidColor,
    required this.alienItem,
  });

  String get wikiUrl {
    final slug = name.replaceAll(' ', '_');
    return 'https://satisfactory.wiki.gg/wiki/$slug';
  }

  String get imagePath => 'assets/images/${name.replaceAll(' ', '_')}.webp';

  bool get isFluid => form == ItemForm.liquid || form == ItemForm.gas;
  bool get isRadioactive => radioactive > 0;

  factory GameItem.fromJson(Map<String, dynamic> json) {
    return GameItem(
      className: json['className'] as String,
      name: json['name'] as String,
      description: (json['description'] as String? ?? '')
          .replaceAll('<br>', '\n')
          .replaceAll(RegExp(r'<[^>]*>'), ''),
      unlockedBy: json['unlockedBy'] as String? ?? '',
      stackSize: (json['stackSize'] as num?)?.toInt() ?? 0,
      energy: (json['energy'] as num?)?.toInt() ?? 0,
      radioactive: (json['radioactive'] as num?)?.toDouble() ?? 0,
      canBeDiscarded: json['canBeDiscarded'] as bool? ?? false,
      sinkPoints: (json['sinkPoints'] as num?)?.toInt() ?? 0,
      abbreviation: json['abbreviation'] as String?,
      form: _parseForm(json['form'] as String?),
      fluidColor: json['fluidColor'] as String? ?? '#ffffff',
      alienItem: json['alienItem'] as bool? ?? false,
    );
  }

  static ItemForm _parseForm(String? form) {
    switch (form) {
      case 'liquid':
        return ItemForm.liquid;
      case 'gas':
        return ItemForm.gas;
      default:
        return ItemForm.solid;
    }
  }
}

class RecipeItem {
  final String className;
  final String name;
  final int amount;
  final GameItem? itemData;

  const RecipeItem({
    required this.className,
    required this.name,
    required this.amount,
    this.itemData,
  });

  String get wikiUrl {
    final slug = name.replaceAll(' ', '_');
    return 'https://satisfactory.wiki.gg/wiki/$slug';
  }

  String get imagePath => 'assets/images/${name.replaceAll(' ', '_')}.webp';

  bool get isFluid => itemData?.isFluid ?? false;

  String get displayAmount {
    if (isFluid) {
      return '${amount}m³';
    }
    return amount.toString();
  }
}
