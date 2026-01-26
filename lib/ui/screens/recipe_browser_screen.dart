import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../widgets/widgets.dart';

class RecipeBrowserScreen extends ConsumerWidget {
  const RecipeBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataLoaded = ref.watch(gameDataLoadedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: dataLoaded.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading game data...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load game data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (_) => const _RecipeList(),
      ),
    );
  }
}

class _RecipeList extends ConsumerWidget {
  const _RecipeList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(filteredRecipesProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        const RecipeSearchBar(),
        const RecipeFilterChips(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${recipes.length} recipes',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: recipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 48,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recipes found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return RecipeFlowMiniCard(
                      recipe: recipe,
                      isSelected: false,
                      onTap: () {
                        context.push('/recipes/${recipe.className}');
                      },
                      onItemTap: (item) {
                        context.push('/items/${item.className}');
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
