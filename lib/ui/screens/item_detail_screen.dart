import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../widgets/header_background.dart';
import '../widgets/item_image.dart';
import '../widgets/recipe_flow_card.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  final String itemClassName;

  const ItemDetailScreen({super.key, required this.itemClassName});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  late String _headerImage;

  @override
  void initState() {
    super.initState();
    _headerImage = pickRandomHeaderBackground();
  }

  @override
  void didUpdateWidget(covariant ItemDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemClassName != widget.itemClassName) {
      _headerImage = pickRandomHeaderBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(allItemsProvider);
    final recipes = ref.watch(allRecipesProvider);
    final item = items[widget.itemClassName];
    final name = item?.name ?? widget.itemClassName;
    final description = item?.description ?? '';

    final recipesForItem =
        recipes
            .where(
              (recipe) => recipe.products.any(
                (product) => product.className == widget.itemClassName,
              ),
            )
            .toList()
          ..sort((a, b) {
            if (a.isAlternate == b.isAlternate) {
              return a.name.compareTo(b.name);
            }
            return a.isAlternate ? 1 : -1;
          });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: description.isNotEmpty ? 300 : 260,
            title: const SizedBox.shrink(),
            backgroundColor: Color(0xFF1A1A2E),
            surfaceTintColor: Color(0xFF1A1A2E),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: HeaderBackground(
                imagePath: _headerImage,
                child: item != null
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GameItemImage(item: item, size: 64),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                ),
                                if (description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.9),
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      )
                    : Text(
                        name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Section(
                    title: 'Recipes',
                    child: recipesForItem.isEmpty
                        ? Text(
                            'No recipes found for this item.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
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
                                      pathParameters: {
                                        'className': recipe.className,
                                      },
                                    );
                                  },
                                  onItemTap: (item) {
                                    context.pushNamed(
                                      'itemDetail',
                                      pathParameters: {
                                        'className': item.className,
                                      },
                                    );
                                  },
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
