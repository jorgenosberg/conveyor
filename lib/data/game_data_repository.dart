import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/models.dart';

class GameDataRepository {
  Map<String, GameItem>? _itemLookup;
  List<Recipe>? _recipes;
  Map<String, String>? _machineNames;

  Future<void> load() async {
    if (_recipes != null) return;

    final itemsJson = await rootBundle.loadString('assets/data/items.json');
    final buildingsJson =
        await rootBundle.loadString('assets/data/buildings.json');
    final recipesJson = await rootBundle.loadString('assets/data/recipes.json');

    _itemLookup = _parseItems(jsonDecode(itemsJson) as Map<String, dynamic>);
    _itemLookup = _parseItems(
      jsonDecode(buildingsJson) as Map<String, dynamic>,
      existing: _itemLookup,
    );
    _machineNames = _buildMachineNames(_itemLookup!);
    _recipes = _parseRecipes(
      jsonDecode(recipesJson) as Map<String, dynamic>,
      _itemLookup!,
    );
  }

  Map<String, GameItem> _parseItems(
    Map<String, dynamic> json, {
    Map<String, GameItem>? existing,
  }) {
    final lookup = existing ?? <String, GameItem>{};
    for (final entry in json.entries) {
      final list = entry.value as List;
      if (list.isNotEmpty) {
        final item = GameItem.fromJson(list.first as Map<String, dynamic>);
        lookup.putIfAbsent(item.className, () => item);
      }
    }
    return lookup;
  }

  Map<String, String> _buildMachineNames(Map<String, GameItem> items) {
    final machines = <String, String>{};
    for (final item in items.values) {
      if (item.className.contains('Mk1') ||
          item.className.contains('Mk2') ||
          item.className.contains('Mk3') ||
          item.className.contains('Constructor') ||
          item.className.contains('Assembler') ||
          item.className.contains('Manufacturer') ||
          item.className.contains('Foundry') ||
          item.className.contains('Smelter') ||
          item.className.contains('Refinery') ||
          item.className.contains('Blender') ||
          item.className.contains('Packager') ||
          item.className.contains('Collider') ||
          item.className.contains('Encoder') ||
          item.className.contains('Converter') ||
          item.className.contains('Generator')) {
        machines[item.className] = item.name;
      }
    }
    // Add common machine name overrides
    machines['Desc_ConstructorMk1_C'] = 'Constructor';
    machines['Desc_AssemblerMk1_C'] = 'Assembler';
    machines['Desc_ManufacturerMk1_C'] = 'Manufacturer';
    machines['Desc_FoundryMk1_C'] = 'Foundry';
    machines['Desc_SmelterMk1_C'] = 'Smelter';
    machines['Desc_OilRefinery_C'] = 'Refinery';
    machines['Desc_Blender_C'] = 'Blender';
    machines['Desc_Packager_C'] = 'Packager';
    machines['Desc_HadronCollider_C'] = 'Particle Accelerator';
    machines['Desc_QuantumEncoder_C'] = 'Quantum Encoder';
    machines['Desc_Converter_C'] = 'Converter';
    machines['Desc_GeneratorNuclear_C'] = 'Nuclear Power Plant';
    machines['Desc_GeneratorCoal_C'] = 'Coal Generator';
    machines['Desc_GeneratorFuel_C'] = 'Fuel Generator';
    machines['Desc_GeneratorBiomass_Automated_C'] = 'Biomass Burner';
    return machines;
  }

  List<Recipe> _parseRecipes(
    Map<String, dynamic> json,
    Map<String, GameItem> itemLookup,
  ) {
    final recipes = <Recipe>[];
    for (final entry in json.entries) {
      final list = entry.value as List;
      for (final recipeJson in list) {
        recipes.add(Recipe.fromJson(
          recipeJson as Map<String, dynamic>,
          itemLookup,
          _resolveMachineName,
        ));
      }
    }
    recipes.sort((a, b) => a.name.compareTo(b.name));
    return recipes;
  }

  String _resolveMachineName(String className) {
    return _machineNames?[className] ?? _fallbackMachineName(className);
  }

  String _fallbackMachineName(String className) {
    return className
        .replaceAll('Desc_', '')
        .replaceAll('_C', '')
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m[1]} ${m[2]}',
        )
        .replaceAll('Mk1', '')
        .trim();
  }

  List<Recipe> get recipes => _recipes ?? [];
  Map<String, GameItem> get items => _itemLookup ?? {};

  List<Recipe> get productionRecipes =>
      recipes.where((r) => r.isProductionRecipe && !r.isBuildRecipe).toList();

  List<Recipe> get buildRecipes =>
      recipes.where((r) => r.isBuildRecipe).toList();

  List<Recipe> get alternateRecipes =>
      recipes.where((r) => r.isAlternate).toList();

  GameItem? getItem(String className) => _itemLookup?[className];
}
