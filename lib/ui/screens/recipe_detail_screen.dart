import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../widgets/item_image.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeClassName;

  const RecipeDetailScreen({
    super.key,
    required this.recipeClassName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(allRecipesProvider);
    final recipe = recipes.firstWhere(
      (r) => r.className == recipeClassName,
      orElse: () => throw Exception('Recipe not found'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open in Wiki',
            onPressed: () => _openWiki(recipe.wikiUrl),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RecipeHeader(recipe: recipe),
            const SizedBox(height: 24),
            _Section(
              title: 'Ingredients',
              child: _ItemTable(items: recipe.ingredients, duration: recipe.duration),
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Products',
              child: _ItemTable(items: recipe.products, duration: recipe.duration),
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Production',
              child: _ProductionInfo(recipe: recipe),
            ),
            if (recipe.unlockedBy.isNotEmpty) ...[
              const SizedBox(height: 24),
              _Section(
                title: 'Unlocked By',
                child: Text(recipe.unlockedBy),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openWiki(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _RecipeHeader extends StatelessWidget {
  final Recipe recipe;

  const _RecipeHeader({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recipe.products.isNotEmpty) ...[
          ItemImage(item: recipe.products.first, size: 64),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipe.isAlternate)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ALTERNATE RECIPE',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                recipe.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
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

class _ItemTable extends StatelessWidget {
  final List<RecipeItem> items;
  final int duration;

  const _ItemTable({
    required this.items,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 40), // Space for image
                Expanded(
                  flex: 3,
                  child: Text(
                    'Item',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Amount',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    '/min',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...items.map((item) => _ItemRow(item: item, duration: duration)),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final RecipeItem item;
  final int duration;

  const _ItemRow({required this.item, required this.duration});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final perMinute = duration > 0 ? (60 / duration) * item.amount : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ItemImage(item: item, size: 32),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => _openWiki(item.wikiUrl),
              child: Text(
                item.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.underline,
                  decorationColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              item.displayAmount,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              perMinute.toStringAsFixed(perMinute.truncateToDouble() == perMinute ? 0 : 2),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWiki(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ProductionInfo extends StatelessWidget {
  final Recipe recipe;

  const _ProductionInfo({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                value: '${recipe.itemsPerMinute.toStringAsFixed(recipe.itemsPerMinute.truncateToDouble() == recipe.itemsPerMinute ? 0 : 2)}/min',
              ),
            ],
          ],
        ),
      ),
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
