import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../widgets/item_image.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeClassName;

  const RecipeDetailScreen({
    super.key,
    required this.recipeClassName,
  });

  @override
  ConsumerState<RecipeDetailScreen> createState() =>
      _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(allRecipesProvider);
    final recipe = recipes.firstWhere(
      (r) => r.className == widget.recipeClassName,
      orElse: () => throw Exception('Recipe not found'),
    );
    final targetProduct =
        recipe.products.isNotEmpty ? recipe.products.first : null;
    final targetClassName = targetProduct?.className ?? recipe.className;
    final recipesForItem = _recipesForItem(recipes, targetClassName);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open in Wiki',
            onPressed: () => _openWikiUrl(recipe.wikiUrl),
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
              title: 'Recipe Flow',
              child: _RecipeFlowCard(recipe: recipe),
            ),
            if (recipesForItem.length > 1) ...[
              const SizedBox(height: 24),
              _Section(
                title:
                    'Recipes for ${targetProduct?.name ?? recipe.primaryProductName}',
                child: Column(
                  children: [
                    for (final related in recipesForItem)
                      _AlternateRecipeFlowCard(
                        recipe: related,
                        isSelected: related.className == recipe.className,
                        onTap: related.className == recipe.className
                            ? null
                            : () {
                                context.pushNamed(
                                  'recipeDetail',
                                  pathParameters: {'className': related.className},
                                );
                              },
                      ),
                  ],
                ),
              ),
            ],
            if (recipe.unlockedBy.isNotEmpty) ...[
              const SizedBox(height: 24),
              _Section(
                title: 'Unlocked By',
                child: Text(recipe.unlockedBy),
              ),
            ],
            const SizedBox(height: 24),
            _Section(
              title: 'Production Chain',
              child: _ProductionCalculator(
                initialRecipe: recipe,
                targetClassName: targetClassName,
                targetName: targetProduct?.name ?? recipe.primaryProductName,
                recipesForItem: recipesForItem,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Recipe> _recipesForItem(List<Recipe> recipes, String className) {
    final matches = recipes
        .where((recipe) =>
            recipe.products.any((product) => product.className == className))
        .toList();
    matches.sort((a, b) {
      if (a.isAlternate == b.isAlternate) {
        return a.name.compareTo(b.name);
      }
      return a.isAlternate ? 1 : -1;
    });
    return matches;
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

class _RecipeFlowCard extends StatelessWidget {
  final Recipe recipe;

  const _RecipeFlowCard({required this.recipe});

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
                    ),
                    const Divider(height: 24),
                    _FlowSection(
                      title: 'Products',
                      items: recipe.products,
                      duration: recipe.duration,
                    ),
                    const Divider(height: 24),
                    _ProductionInfo(recipe: recipe),
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
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FlowSection(
                          title: 'Products',
                          items: recipe.products,
                          duration: recipe.duration,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 220,
                        child: _ProductionInfo(recipe: recipe),
                      ),
                    ],
                  ),
                ),
        ),
      );
    });
  }
}

class _AlternateRecipeFlowCard extends StatelessWidget {
  final Recipe recipe;
  final bool isSelected;
  final VoidCallback? onTap;

  const _AlternateRecipeFlowCard({
    required this.recipe,
    required this.isSelected,
    this.onTap,
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FlowSection(
                      title: 'Outputs',
                      items: recipe.products,
                      duration: recipe.duration,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${recipe.producedIn.isNotEmpty ? recipe.producedIn.join(', ') : recipe.inCraftBench ? 'Craft Bench' : 'Build Gun'} • ${recipe.duration}s • ${recipe.itemsPerMinute.toStringAsFixed(recipe.itemsPerMinute.truncateToDouble() == recipe.itemsPerMinute ? 0 : 2)}/min',
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

class _FlowSection extends StatelessWidget {
  final String title;
  final List<RecipeItem> items;
  final int duration;

  const _FlowSection({
    required this.title,
    required this.items,
    required this.duration,
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
                    onTap: () {
                      context.pushNamed(
                        'itemDetail',
                        pathParameters: {'className': item.className},
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
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

class _ProductionInfo extends StatelessWidget {
  final Recipe recipe;

  const _ProductionInfo({required this.recipe});

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
            value: '${recipe.itemsPerMinute.toStringAsFixed(recipe.itemsPerMinute.truncateToDouble() == recipe.itemsPerMinute ? 0 : 2)}/min',
          ),
        ],
      ],
    );
  }
}

class _ProductionCalculator extends ConsumerStatefulWidget {
  final Recipe initialRecipe;
  final String targetClassName;
  final String targetName;
  final List<Recipe> recipesForItem;

  const _ProductionCalculator({
    required this.initialRecipe,
    required this.targetClassName,
    required this.targetName,
    required this.recipesForItem,
  });

  @override
  ConsumerState<_ProductionCalculator> createState() =>
      _ProductionCalculatorState();
}

class _ProductionCalculatorState extends ConsumerState<_ProductionCalculator> {
  late Recipe _selectedRecipe;
  late TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _selectedRecipe = widget.initialRecipe;
    _rateController = TextEditingController(
      text: _formatNumber(_defaultRate(_selectedRecipe)),
    );
  }

  @override
  void didUpdateWidget(covariant _ProductionCalculator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRecipe.className != widget.initialRecipe.className ||
        oldWidget.targetClassName != widget.targetClassName) {
      _selectedRecipe = widget.initialRecipe;
      _rateController.text = _formatNumber(_defaultRate(_selectedRecipe));
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planner = ref.watch(productionPlannerProvider);
    final targetRate = _parseRate(
      _rateController.text,
      fallback: _defaultRate(_selectedRecipe),
    );

    final plan = targetRate > 0
        ? planner.buildPlan(
            recipe: _selectedRecipe,
            targetClassName: widget.targetClassName,
            targetRatePerMinute: targetRate,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.recipesForItem.length > 1) ...[
          DropdownButtonFormField<Recipe>(
            value: _selectedRecipe,
            decoration: const InputDecoration(
              labelText: 'Recipe',
            ),
            items: [
              for (final recipe in widget.recipesForItem)
                DropdownMenuItem(
                  value: recipe,
                  child: Text(recipe.name),
                ),
            ],
            onChanged: (recipe) {
              if (recipe == null) return;
              setState(() {
                _selectedRecipe = recipe;
                _rateController.text = _formatNumber(_defaultRate(recipe));
              });
            },
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _rateController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Target output',
            helperText: 'Units per minute of ${widget.targetName}',
            suffixText: '/min',
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        if (plan == null)
          Text(
            'Enter a target output rate to calculate the production chain.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          )
        else ...[
          _ProductionPlanView(plan: plan),
          const SizedBox(height: 16),
          _ProductionSummary(plan: plan),
        ],
      ],
    );
  }

  double _defaultRate(Recipe recipe) {
    final rate = recipe.outputPerMinuteFor(widget.targetClassName);
    if (rate > 0) return rate;
    return recipe.itemsPerMinute;
  }
}

class _ProductionPlanView extends StatelessWidget {
  final ProductionPlanNode plan;

  const _ProductionPlanView({required this.plan});

  @override
  Widget build(BuildContext context) {
    final entries = <_PlanEntry>[];

    void walk(ProductionPlanNode node, int depth) {
      entries.add(_PlanEntry(node: node, depth: depth));
      for (final child in node.inputs) {
        walk(child, depth + 1);
      }
    }

    walk(plan, 0);

    return Column(
      children: entries
          .map((entry) => _PlanRow(node: entry.node, depth: entry.depth))
          .toList(),
    );
  }
}

class _PlanEntry {
  final ProductionPlanNode node;
  final int depth;

  const _PlanEntry({required this.node, required this.depth});
}

class _PlanRow extends StatelessWidget {
  final ProductionPlanNode node;
  final int depth;

  const _PlanRow({required this.node, required this.depth});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indent = depth * 16.0;
    final rateLabel = '${_formatNumber(node.ratePerMinute)}/min';

    return Padding(
      padding: EdgeInsets.only(left: indent, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemImage(item: node.item, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.item.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  node.machineLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rateLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                node.isRaw
                    ? 'Raw'
                    : '${_formatNumber(node.machines)} machine${node.machines == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductionSummary extends StatelessWidget {
  final ProductionPlanNode plan;

  const _ProductionSummary({required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final machineTotals = <String, double>{};
    final rawTotals = <String, double>{};

    void walk(ProductionPlanNode node) {
      if (node.isRaw) {
        rawTotals[node.item.name] =
            (rawTotals[node.item.name] ?? 0) + node.ratePerMinute;
      } else {
        final machine = node.machineLabel;
        machineTotals[machine] = (machineTotals[machine] ?? 0) + node.machines;
      }
      for (final child in node.inputs) {
        walk(child);
      }
    }

    walk(plan);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Machines',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            if (machineTotals.isEmpty)
              Text(
                'No machines required.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            else
              ...machineTotals.entries
                  .map((entry) => _SummaryRow(
                        label: entry.key,
                        value: _formatNumber(entry.value),
                      ))
                  .toList(),
            const SizedBox(height: 16),
            Text(
              'Raw Resources (/min)',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            if (rawTotals.isEmpty)
              Text(
                'No raw resources required.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              )
            else
              ...rawTotals.entries
                  .map((entry) => _SummaryRow(
                        label: entry.key,
                        value: '${_formatNumber(entry.value)}/min',
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _openWikiUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

double _parseRate(String raw, {required double fallback}) {
  final cleaned = raw.replaceAll(',', '.').trim();
  final value = double.tryParse(cleaned);
  if (value == null || value <= 0) return fallback;
  return value;
}

String _formatNumber(double value) {
  if (value.isNaN || value.isInfinite) return '0';
  final absValue = value.abs();
  final decimals = absValue >= 100 ? 0 : absValue >= 1 ? 2 : 3;
  final text = value.toStringAsFixed(decimals);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
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
