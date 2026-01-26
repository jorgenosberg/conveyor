import 'package:flutter/material.dart';

import '../../models/models.dart';
import 'item_image.dart';

class RecipeFlowCard extends StatelessWidget {
  final Recipe recipe;
  final void Function(RecipeItem item)? onItemTap;

  const RecipeFlowCard({
    super.key,
    required this.recipe,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 700;
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FlowSection(
                      title: 'Ingredients',
                      items: recipe.ingredients,
                      duration: recipe.duration,
                      onItemTap: onItemTap,
                    ),
                    const Divider(height: 24),
                    _FlowSection(
                      title: 'Products',
                      items: recipe.products,
                      duration: recipe.duration,
                      onItemTap: onItemTap,
                    ),
                    const Divider(height: 24),
                    RecipeProductionInfo(recipe: recipe),
                  ],
                )
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _FlowSection(
                          title: 'Ingredients',
                          items: recipe.ingredients,
                          duration: recipe.duration,
                          onItemTap: onItemTap,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FlowSection(
                          title: 'Products',
                          items: recipe.products,
                          duration: recipe.duration,
                          onItemTap: onItemTap,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 220,
                        child: RecipeProductionInfo(recipe: recipe),
                      ),
                    ],
                  ),
                ),
        ),
      );
    });
  }
}

class RecipeFlowMiniCard extends StatelessWidget {
  final Recipe recipe;
  final bool isSelected;
  final VoidCallback? onTap;
  final void Function(RecipeItem item)? onItemTap;

  const RecipeFlowMiniCard({
    super.key,
    required this.recipe,
    required this.isSelected,
    this.onTap,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = isSelected
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : theme.colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _FlowSection(
                      title: 'Inputs',
                      items: recipe.ingredients,
                      duration: recipe.duration,
                      onItemTap: onItemTap,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FlowSection(
                      title: 'Outputs',
                      items: recipe.products,
                      duration: recipe.duration,
                      onItemTap: onItemTap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${recipe.producedIn.isNotEmpty ? recipe.producedIn.join(', ') : recipe.inCraftBench ? 'Craft Bench' : 'Build Gun'} • ${recipe.duration}s • ${_formatNumber(recipe.itemsPerMinute)}/min',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecipeProductionInfo extends StatelessWidget {
  final Recipe recipe;

  const RecipeProductionInfo({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(
          icon: Icons.precision_manufacturing,
          label: 'Produced In',
          value: recipe.producedIn.isNotEmpty
              ? recipe.producedIn.join(', ')
              : recipe.inCraftBench
                  ? 'Craft Bench'
                  : 'Build Gun',
        ),
        const SizedBox(height: 12),
        _InfoRow(
          icon: Icons.timer_outlined,
          label: 'Cycle Time',
          value: '${recipe.duration} seconds',
        ),
        if (recipe.products.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.speed,
            label: 'Output Rate',
            value:
                '${_formatNumber(recipe.itemsPerMinute)}/min',
          ),
        ],
      ],
    );
  }
}

class _FlowSection extends StatelessWidget {
  final String title;
  final List<RecipeItem> items;
  final int duration;
  final void Function(RecipeItem item)? onItemTap;

  const _FlowSection({
    required this.title,
    required this.items,
    required this.duration,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Text(
        'No $title.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) {
          final perMinute = duration > 0 ? (60 / duration) * item.amount : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ItemAmountTile(item: item),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onItemTap == null ? null : () => onItemTap!(item),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: onItemTap == null
                                ? TextDecoration.none
                                : TextDecoration.underline,
                          ),
                        ),
                        Text(
                          '${_formatNumber(perMinute)}/min',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ItemAmountTile extends StatelessWidget {
  final RecipeItem item;

  const _ItemAmountTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tileColor = theme.colorScheme.surface.withValues(alpha: 0.6);
    final badgeColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final badgeTextColor = theme.colorScheme.surface;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: ItemImage(item: item, size: 36),
          ),
        ),
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item.displayAmount,
              style: theme.textTheme.labelSmall?.copyWith(
                color: badgeTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
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
          ),
        ),
      ],
    );
  }
}

String _formatNumber(double value) {
  if (value.isNaN || value.isInfinite) return '0';
  final absValue = value.abs();
  final decimals = absValue >= 100 ? 0 : absValue >= 1 ? 2 : 3;
  final text = value.toStringAsFixed(decimals);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}
