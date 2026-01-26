import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'game_data_provider.dart';

enum RecipeFilter { all, production, alternate, building }

final searchQueryProvider = StateProvider<String>((ref) => '');

final recipeFilterProvider = StateProvider<RecipeFilter>(
  (ref) => RecipeFilter.production,
);

final filteredRecipesProvider = Provider<List<Recipe>>((ref) {
  final filter = ref.watch(recipeFilterProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final repository = ref.watch(gameDataRepositoryProvider);

  List<Recipe> recipes;
  switch (filter) {
    case RecipeFilter.all:
      recipes = repository.recipes;
      break;
    case RecipeFilter.production:
      recipes = repository.productionRecipes;
      break;
    case RecipeFilter.alternate:
      recipes = repository.alternateRecipes;
      break;
    case RecipeFilter.building:
      recipes = repository.buildRecipes;
      break;
  }

  if (query.isEmpty) return recipes;

  return recipes.where((recipe) {
    if (recipe.name.toLowerCase().contains(query)) return true;
    if (recipe.primaryProductName.toLowerCase().contains(query)) return true;
    for (final ingredient in recipe.ingredients) {
      if (ingredient.name.toLowerCase().contains(query)) return true;
    }
    for (final product in recipe.products) {
      if (product.name.toLowerCase().contains(query)) return true;
    }
    if (recipe.producedIn.any((m) => m.toLowerCase().contains(query))) {
      return true;
    }
    return false;
  }).toList();
});

final selectedRecipeProvider = StateProvider<Recipe?>((ref) => null);
