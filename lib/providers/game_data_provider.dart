import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/game_data_repository.dart';
import '../data/production_planner.dart';
import '../models/models.dart';

final gameDataRepositoryProvider = Provider<GameDataRepository>((ref) {
  return GameDataRepository();
});

final gameDataLoadedProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(gameDataRepositoryProvider);
  await repository.load();
});

final allRecipesProvider = Provider<List<Recipe>>((ref) {
  final repository = ref.watch(gameDataRepositoryProvider);
  return repository.recipes;
});

final productionRecipesProvider = Provider<List<Recipe>>((ref) {
  final repository = ref.watch(gameDataRepositoryProvider);
  return repository.productionRecipes;
});

final alternateRecipesProvider = Provider<List<Recipe>>((ref) {
  final repository = ref.watch(gameDataRepositoryProvider);
  return repository.alternateRecipes;
});

final buildRecipesProvider = Provider<List<Recipe>>((ref) {
  final repository = ref.watch(gameDataRepositoryProvider);
  return repository.buildRecipes;
});

final allItemsProvider = Provider<Map<String, GameItem>>((ref) {
  final repository = ref.watch(gameDataRepositoryProvider);
  return repository.items;
});

final productionPlannerProvider = Provider<ProductionPlanner>((ref) {
  final recipes = ref.watch(allRecipesProvider);
  return ProductionPlanner(recipes);
});
