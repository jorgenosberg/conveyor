import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../widgets/widgets.dart';

class ItemBrowserScreen extends ConsumerWidget {
  const ItemBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataLoaded = ref.watch(gameDataLoadedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Items'), actions: [_ViewModeToggle()]),
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
        data: (_) => const _ItemList(),
      ),
    );
  }
}

class _ViewModeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(itemViewModeProvider);

    return IconButton(
      icon: Icon(
        viewMode == ItemViewMode.grid ? Icons.view_list : Icons.grid_view,
      ),
      tooltip: viewMode == ItemViewMode.grid ? 'List view' : 'Grid view',
      onPressed: () {
        ref
            .read(itemViewModeProvider.notifier)
            .state = viewMode == ItemViewMode.grid
            ? ItemViewMode.list
            : ItemViewMode.grid;
      },
    );
  }
}

class _ItemList extends ConsumerWidget {
  const _ItemList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(filteredItemsProvider);
    final viewMode = ref.watch(itemViewModeProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        const _ItemSearchBar(),
        const _ItemFilterChips(),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${items.length} items',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: items.isEmpty
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
                        'No items found',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : viewMode == ItemViewMode.grid
              ? _ItemGridView(items: items)
              : _ItemListView(items: items),
        ),
      ],
    );
  }
}

class _ItemSearchBar extends ConsumerWidget {
  const _ItemSearchBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(itemSearchQueryProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search items...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    ref.read(itemSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
        ),
        onChanged: (value) {
          ref.read(itemSearchQueryProvider.notifier).state = value;
        },
      ),
    );
  }
}

class _ItemFilterChips extends ConsumerWidget {
  const _ItemFilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(itemFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final filter in ItemFilter.values) ...[
            FilterChip(
              label: Text(_filterLabel(filter)),
              selected: selectedFilter == filter,
              onSelected: (selected) {
                ref.read(itemFilterProvider.notifier).state = selected
                    ? filter
                    : ItemFilter.all;
              },
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  String _filterLabel(ItemFilter filter) {
    return switch (filter) {
      ItemFilter.all => 'All',
      ItemFilter.solid => 'Solid',
      ItemFilter.liquid => 'Liquid',
      ItemFilter.gas => 'Gas',
    };
  }
}

class _ItemGridView extends StatelessWidget {
  final List<GameItem> items;

  const _ItemGridView({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 120,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemGridCard(
          item: item,
          onTap: () {
            context.push('/items/${item.className}');
          },
        );
      },
    );
  }
}

class _ItemListView extends StatelessWidget {
  final List<GameItem> items;

  const _ItemListView({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemListCard(
          item: item,
          onTap: () {
            context.push('/items/${item.className}');
          },
        );
      },
    );
  }
}
