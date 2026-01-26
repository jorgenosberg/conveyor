import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../widgets/item_image.dart';
import '../widgets/recipe_flow_card.dart';

class ItemDetailScreen extends ConsumerWidget {
  final String itemClassName;

  const ItemDetailScreen({
    super.key,
    required this.itemClassName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(allItemsProvider);
    final recipes = ref.watch(allRecipesProvider);
    final item = items[itemClassName];
    final name = item?.name ?? itemClassName;
    final description = item?.description ?? '';

    final recipesForItem = recipes
        .where((recipe) =>
            recipe.products.any((product) => product.className == itemClassName))
        .toList()
      ..sort((a, b) {
        if (a.isAlternate == b.isAlternate) {
          return a.name.compareTo(b.name);
        }
        return a.isAlternate ? 1 : -1;
      });

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GameItemImage(item: item, size: 72),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(description),
                        ],
                      ],
                    ),
                  ),
                ],
              )
            else
              Text(
                name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 24),
            _Section(
              title: 'Recipes',
              child: recipesForItem.isEmpty
                  ? Text(
                      'No recipes found for this item.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    )
                  : Column(
                      children: [
                        for (final recipe in recipesForItem)
                          RecipeFlowMiniCard(
                            recipe: recipe,
                            isSelected: false,
                            onTap: () {
                              context.pushNamed(
                                'recipeDetail',
                                pathParameters: {'className': recipe.className},
                              );
                            },
                            onItemTap: (item) {
                              context.pushNamed(
                                'itemDetail',
                                pathParameters: {'className': item.className},
                              );
                            },
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
