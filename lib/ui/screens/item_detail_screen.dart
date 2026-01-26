import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/header_background.dart';
import '../widgets/item_image.dart';
import '../widgets/recipe_flow_card.dart';
import '../widgets/common.dart';

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
    // Track view in recents
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentItemsProvider.notifier).add(widget.itemClassName);
    });
  }

  @override
  void didUpdateWidget(covariant ItemDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemClassName != widget.itemClassName) {
      _headerImage = pickRandomHeaderBackground();
      ref.read(recentItemsProvider.notifier).add(widget.itemClassName);
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
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            elevation: 0,
            actions: [
              if (item != null)
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'Open in Wiki',
                  onPressed: () => _openWikiUrl(item.wikiUrl),
                ),
            ],
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
                  // Item stats section
                  if (item != null) ...[
                    ContentSection(
                      title: 'Properties',
                      child: _ItemStatsCard(item: item),
                    ),
                    const SizedBox(height: 24),
                  ],
                  ContentSection(
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
                                    context.push(
                                      '/recipes/${recipe.className}',
                                    );
                                  },
                                  onItemTap: (item) {
                                    context.push(
                                      '/items/${item.className}',
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

  Future<void> _openWikiUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ItemStatsCard extends StatelessWidget {
  final GameItem item;

  const _ItemStatsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _StatRow(
            icon: Icons.category_outlined,
            label: 'Form',
            value: _formLabel(item.form),
          ),
          if (item.stackSize > 0) ...[
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.layers_outlined,
              label: 'Stack Size',
              value: item.stackSize.toString(),
            ),
          ],
          if (item.sinkPoints > 0) ...[
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.recycling_outlined,
              label: 'Sink Points',
              value: formatNumber(item.sinkPoints.toDouble()),
            ),
          ],
          if (item.energy > 0) ...[
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.bolt_outlined,
              label: 'Energy',
              value: '${formatNumber(item.energy.toDouble())} MJ',
            ),
          ],
          if (item.isRadioactive) ...[
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.warning_amber_outlined,
              label: 'Radioactive',
              value: item.radioactive.toString(),
              valueColor: AppColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  String _formLabel(ItemForm form) {
    return switch (form) {
      ItemForm.solid => 'Solid',
      ItemForm.liquid => 'Liquid',
      ItemForm.gas => 'Gas',
    };
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
