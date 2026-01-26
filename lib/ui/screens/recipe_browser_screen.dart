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
      appBar: AppBar(title: const Text('Recipes')),
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
              const Spacer(),
              const _RecipeSortButton(),
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
                      showTitle: true,
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

class _RecipeSortButton extends ConsumerWidget {
  const _RecipeSortButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortMode = ref.watch(recipeSortModeProvider);
    return Tooltip(
      message: 'Sort: ${_recipeSortLabel(sortMode)}',
      child: TextButton.icon(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            builder: (context) => const _RecipeSortSheet(),
          );
        },
        icon: const Icon(Icons.sort),
        label: const Text('Sort'),
      ),
    );
  }
}

class _RecipeSortSheet extends ConsumerWidget {
  const _RecipeSortSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortMode = ref.watch(recipeSortModeProvider);
    final preferStandard = ref.watch(preferStandardRecipesProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Sort recipes',
              style: theme.textTheme.titleMedium,
            ),
          ),
          for (final mode in RecipeSortMode.values)
            RadioListTile<RecipeSortMode>(
              value: mode,
              groupValue: sortMode,
              title: Text(_recipeSortLabel(mode)),
              onChanged: (value) {
                if (value == null) return;
                ref.read(recipeSortModeProvider.notifier).state = value;
              },
            ),
          const Divider(),
          SwitchListTile(
            title: const Text('Prefer standard recipes in search'),
            subtitle: const Text(
              'Alternate recipes appear lower in relevance results.',
            ),
            value: preferStandard,
            onChanged: (value) {
              ref.read(preferStandardRecipesProvider.notifier).state = value;
            },
          ),
        ],
      ),
    );
  }
}

String _recipeSortLabel(RecipeSortMode mode) {
  return switch (mode) {
    RecipeSortMode.relevance => 'Relevance',
    RecipeSortMode.nameAsc => 'Name (A-Z)',
    RecipeSortMode.nameDesc => 'Name (Z-A)',
    RecipeSortMode.outputDesc => 'Output rate (high to low)',
    RecipeSortMode.outputAsc => 'Output rate (low to high)',
  };
}
