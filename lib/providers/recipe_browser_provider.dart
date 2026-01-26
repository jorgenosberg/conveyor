import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'game_data_provider.dart';

enum RecipeFilter { all, production, alternate, building }

enum RecipeSortMode {
  relevance,
  nameAsc,
  nameDesc,
  outputDesc,
  outputAsc,
}

final searchQueryProvider = StateProvider<String>((ref) => '');

final recipeFilterProvider = StateProvider<RecipeFilter>(
  (ref) => RecipeFilter.production,
);

final recipeSortModeProvider = StateProvider<RecipeSortMode>(
  (ref) => RecipeSortMode.relevance,
);

final preferStandardRecipesProvider = StateProvider<bool>((ref) => true);

final filteredRecipesProvider = Provider<List<Recipe>>((ref) {
  final filter = ref.watch(recipeFilterProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final sortMode = ref.watch(recipeSortModeProvider);
  final preferStandard = ref.watch(preferStandardRecipesProvider);
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

  if (query.isEmpty) {
    final list = List<Recipe>.from(recipes);
    _sortRecipes(list, sortMode);
    return list;
  }

  final scored = <MapEntry<Recipe, int>>[];
  final filtered = <Recipe>[];
  for (final recipe in recipes) {
    final score = _scoreRecipe(recipe, query, preferStandard: preferStandard);
    if (score > 0) {
      scored.add(MapEntry(recipe, score));
      filtered.add(recipe);
    }
  }

  if (sortMode == RecipeSortMode.relevance) {
    scored.sort((a, b) {
      final scoreCompare = b.value.compareTo(a.value);
      if (scoreCompare != 0) return scoreCompare;
      return a.key.name.compareTo(b.key.name);
    });
    return scored.map((entry) => entry.key).toList();
  }

  _sortRecipes(filtered, sortMode);
  return filtered;
});

final selectedRecipeProvider = StateProvider<Recipe?>((ref) => null);

final _wordSplitRegex = RegExp(r'[^a-z0-9]+');

int _scoreRecipe(
  Recipe recipe,
  String query, {
  required bool preferStandard,
}) {
  final nameScore = _fieldScore(
    recipe.name,
    query,
    exact: 100,
    startsWithScore: 90,
    wordStart: 80,
    contains: 70,
  );
  final primaryScore = _fieldScore(
    recipe.primaryProductName,
    query,
    exact: 90,
    startsWithScore: 80,
    wordStart: 70,
    contains: 60,
  );
  final productScore = _maxFieldScore(
    recipe.products.map((p) => p.name),
    query,
    exact: 70,
    startsWithScore: 60,
    wordStart: 50,
    contains: 40,
  );
  final ingredientScore = _maxFieldScore(
    recipe.ingredients.map((i) => i.name),
    query,
    exact: 35,
    startsWithScore: 30,
    wordStart: 25,
    contains: 20,
  );
  final machineScore = _maxFieldScore(
    recipe.producedIn,
    query,
    exact: 20,
    startsWithScore: 15,
    wordStart: 10,
    contains: 8,
  );

  final baseScore =
      nameScore + primaryScore + productScore + ingredientScore + machineScore;

  var score = baseScore;
  if (preferStandard && recipe.isAlternate) {
    score -= 12;
  }

  if (baseScore > 0 && score <= 0) return 1;
  return score < 0 ? 0 : score;
}

void _sortRecipes(List<Recipe> recipes, RecipeSortMode mode) {
  int compareOutput(Recipe a, Recipe b) {
    final outputCompare = b.itemsPerMinute.compareTo(a.itemsPerMinute);
    if (outputCompare != 0) return outputCompare;
    return a.name.compareTo(b.name);
  }

  switch (mode) {
    case RecipeSortMode.relevance:
    case RecipeSortMode.nameAsc:
      recipes.sort((a, b) => a.name.compareTo(b.name));
      break;
    case RecipeSortMode.nameDesc:
      recipes.sort((a, b) => b.name.compareTo(a.name));
      break;
    case RecipeSortMode.outputDesc:
      recipes.sort(compareOutput);
      break;
    case RecipeSortMode.outputAsc:
      recipes.sort((a, b) => compareOutput(b, a));
      break;
  }
}

int _maxFieldScore(
  Iterable<String> fields,
  String query, {
  required int exact,
  required int startsWithScore,
  required int wordStart,
  required int contains,
}) {
  var best = 0;
  for (final field in fields) {
    final score = _fieldScore(
      field,
      query,
      exact: exact,
      startsWithScore: startsWithScore,
      wordStart: wordStart,
      contains: contains,
    );
    if (score > best) best = score;
  }
  return best;
}

int _fieldScore(
  String field,
  String query, {
  required int exact,
  required int startsWithScore,
  required int wordStart,
  required int contains,
}) {
  final text = field.toLowerCase();
  if (text == query) return exact;
  if (text.startsWith(query)) return startsWithScore;
  if (_wordStartsWith(text, query)) return wordStart;
  if (text.contains(query)) return contains;
  return 0;
}

bool _wordStartsWith(String text, String query) {
  for (final word in text.split(_wordSplitRegex)) {
    if (word.isNotEmpty && word.startsWith(query)) return true;
  }
  return false;
}
