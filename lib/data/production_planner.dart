import '../models/models.dart';

const _rawResourceClassNames = <String>{
  'Desc_OreIron_C',
  'Desc_OreCopper_C',
  'Desc_Stone_C',
  'Desc_Coal_C',
  'Desc_RawQuartz_C',
  'Desc_Sulfur_C',
  'Desc_OreGold_C',
  'Desc_OreBauxite_C',
  'Desc_OreUranium_C',
  'Desc_SAM_C',
  'Desc_LiquidOil_C',
  'Desc_Water_C',
  'Desc_NitrogenGas_C',
};

class ProductionPlanner {
  final List<Recipe> recipes;
  final Map<String, List<Recipe>> _recipesByProduct;

  ProductionPlanner(this.recipes) : _recipesByProduct = _indexRecipes(recipes);

  ProductionPlanNode buildPlan({
    required Recipe recipe,
    required String targetClassName,
    required double targetRatePerMinute,
  }) {
    return _buildNode(
      recipe: recipe,
      targetClassName: targetClassName,
      targetRatePerMinute: targetRatePerMinute,
      visiting: <String>{targetClassName},
    );
  }

  Recipe? defaultRecipeFor(String className) {
    if (_rawResourceClassNames.contains(className)) return null;
    final candidates = _recipesByProduct[className] ?? [];
    if (candidates.isEmpty) return null;
    final production = candidates
        .where((r) => r.isProductionRecipe && !r.isBuildRecipe)
        .toList();
    final packagedTarget = _isPackagedTarget(candidates, className);
    final nonConverter = production.where((r) {
      if (_isConverterRecipe(r)) return false;
      if (_isPackagerRecipe(r) && !packagedTarget) return false;
      return true;
    }).toList();
    if (production.isNotEmpty && nonConverter.isEmpty) {
      return null;
    }
    final base = nonConverter.where((r) => !r.isAlternate).toList();
    if (base.isNotEmpty) return base.first;
    if (nonConverter.isNotEmpty) return nonConverter.first;
    return null;
  }

  ProductionPlanNode _buildNode({
    required Recipe recipe,
    required String targetClassName,
    required double targetRatePerMinute,
    required Set<String> visiting,
  }) {
    final product =
        recipe.productFor(targetClassName) ?? recipe.products.firstOrNull;
    if (product == null || recipe.duration <= 0) {
      return ProductionPlanNode(
        item: _fallbackItem(targetClassName, recipe),
        recipe: recipe,
        ratePerMinute: targetRatePerMinute,
        machines: 0,
        inputs: const [],
      );
    }

    final perMachineOutput =
        (60.0 / recipe.duration) * product.amount.toDouble();
    final machines = perMachineOutput > 0
        ? targetRatePerMinute / perMachineOutput
        : 0.0;

    final inputs = <ProductionPlanNode>[];
    for (final ingredient in recipe.ingredients) {
      final perMachineInput =
          (60.0 / recipe.duration) * ingredient.amount.toDouble();
      final requiredRate = perMachineInput * machines;

      if (visiting.contains(ingredient.className)) {
        inputs.add(
          ProductionPlanNode(
            item: ingredient,
            recipe: null,
            ratePerMinute: requiredRate,
            machines: 0,
            inputs: const [],
          ),
        );
        continue;
      }

      final nextRecipe = defaultRecipeFor(ingredient.className);
      if (nextRecipe == null) {
        inputs.add(
          ProductionPlanNode(
            item: ingredient,
            recipe: null,
            ratePerMinute: requiredRate,
            machines: 0,
            inputs: const [],
          ),
        );
        continue;
      }

      inputs.add(
        _buildNode(
          recipe: nextRecipe,
          targetClassName: ingredient.className,
          targetRatePerMinute: requiredRate,
          visiting: {...visiting, ingredient.className},
        ),
      );
    }

    return ProductionPlanNode(
      item: product,
      recipe: recipe,
      ratePerMinute: targetRatePerMinute,
      machines: machines,
      inputs: inputs,
    );
  }

  RecipeItem _fallbackItem(String className, Recipe recipe) {
    final existing = recipe.products.firstWhere(
      (item) => item.className == className,
      orElse: () =>
          RecipeItem(className: className, name: className, amount: 0),
    );
    return existing;
  }

  static Map<String, List<Recipe>> _indexRecipes(List<Recipe> recipes) {
    final map = <String, List<Recipe>>{};
    for (final recipe in recipes) {
      for (final product in recipe.products) {
        map.putIfAbsent(product.className, () => []).add(recipe);
      }
    }
    for (final entry in map.entries) {
      entry.value.sort((a, b) {
        if (a.isAlternate == b.isAlternate) {
          return a.name.compareTo(b.name);
        }
        return a.isAlternate ? 1 : -1;
      });
    }
    return map;
  }
}

extension _RecipeListExtensions on List<RecipeItem> {
  RecipeItem? get firstOrNull => isEmpty ? null : first;
}

bool _isConverterRecipe(Recipe recipe) {
  return recipe.producedIn.any(
    (machine) => machine.toLowerCase().contains('converter'),
  );
}

bool _isPackagerRecipe(Recipe recipe) {
  return recipe.producedIn.any(
    (machine) => machine.toLowerCase().contains('packager'),
  );
}

bool _isPackagedTarget(List<Recipe> candidates, String className) {
  for (final recipe in candidates) {
    final product = recipe.productFor(className);
    if (product == null) continue;
    final name = product.name.toLowerCase();
    if (name.startsWith('packaged ')) return true;
  }
  return className.toLowerCase().contains('packaged');
}
