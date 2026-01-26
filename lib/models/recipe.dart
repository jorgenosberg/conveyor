import 'item.dart';

class Recipe {
  final String className;
  final String name;
  final String unlockedBy;
  final int duration;
  final List<RecipeItem> ingredients;
  final List<RecipeItem> products;
  final List<String> producedIn;
  final bool inCraftBench;
  final bool inWorkshop;
  final bool inBuildGun;
  final bool inCustomizer;
  final bool alternate;

  const Recipe({
    required this.className,
    required this.name,
    required this.unlockedBy,
    required this.duration,
    required this.ingredients,
    required this.products,
    required this.producedIn,
    required this.inCraftBench,
    required this.inWorkshop,
    required this.inBuildGun,
    required this.inCustomizer,
    required this.alternate,
  });

  bool get isProductionRecipe => producedIn.isNotEmpty || inCraftBench;
  bool get isBuildRecipe => inBuildGun;
  bool get isAlternate => alternate;

  RecipeItem? productFor(String className) {
    for (final product in products) {
      if (product.className == className) return product;
    }
    return null;
  }

  double outputPerMinuteFor(String className) {
    if (duration <= 0) return 0;
    final product = productFor(className);
    if (product == null) return 0;
    return (60 / duration) * product.amount;
  }

  String get primaryProductName =>
      products.isNotEmpty ? products.first.name : name;

  String get wikiUrl {
    final slug = primaryProductName.replaceAll(' ', '_');
    return 'https://satisfactory.wiki.gg/wiki/$slug';
  }

  double get itemsPerMinute {
    if (duration <= 0 || products.isEmpty) return 0;
    return (60 / duration) * products.first.amount;
  }

  factory Recipe.fromJson(
    Map<String, dynamic> json,
    Map<String, GameItem> itemLookup,
    String Function(String) machineNameResolver,
  ) {
    return Recipe(
      className: json['className'] as String,
      name: json['name'] as String,
      unlockedBy: _cleanUnlockedBy(json['unlockedBy'] as String? ?? ''),
      duration: (json['duration'] as num).toInt(),
      ingredients: _parseItems(json['ingredients'] as List, itemLookup),
      products: _parseItems(json['products'] as List, itemLookup),
      producedIn: (json['producedIn'] as List)
          .map((e) => machineNameResolver(e as String))
          .toList(),
      inCraftBench: json['inCraftBench'] as bool? ?? false,
      inWorkshop: json['inWorkshop'] as bool? ?? false,
      inBuildGun: json['inBuildGun'] as bool? ?? false,
      inCustomizer: json['inCustomizer'] as bool? ?? false,
      alternate: json['alternate'] as bool? ?? false,
    );
  }

  static List<RecipeItem> _parseItems(
    List items,
    Map<String, GameItem> itemLookup,
  ) {
    return items.map((e) {
      final json = e as Map<String, dynamic>;
      final className = json['item'] as String;
      final itemData = itemLookup[className];
      return RecipeItem(
        className: className,
        name: itemData?.name ?? _fallbackName(className),
        amount: (json['amount'] as num).toInt(),
        itemData: itemData,
      );
    }).toList();
  }

  static String _fallbackName(String className) {
    return className
        .replaceAll('Desc_', '')
        .replaceAll('BP_EquipmentDescriptor', '')
        .replaceAll('BP_ItemDescriptor', '')
        .replaceAll('BP_EqDesc', '')
        .replaceAll('_C', '')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m[1]} ${m[2]}',
        )
        .replaceAll('_', ' ')
        .trim();
  }

  static String _cleanUnlockedBy(String raw) {
    return raw
        .replaceAll(RegExp(r'\[\[([^\]|]+)\|?[^\]]*\]\]'), r'\1')
        .replaceAll('<br>', ', ')
        .replaceAll(' OR', ',')
        .trim();
  }
}
