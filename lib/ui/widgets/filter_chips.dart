import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';

class RecipeFilterChips extends ConsumerWidget {
  const RecipeFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(recipeFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: RecipeFilter.values.map((filter) {
          final isSelected = filter == currentFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(_filterLabel(filter)),
              onSelected: (_) {
                ref.read(recipeFilterProvider.notifier).state = filter;
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _filterLabel(RecipeFilter filter) {
    switch (filter) {
      case RecipeFilter.all:
        return 'All';
      case RecipeFilter.production:
        return 'Production';
      case RecipeFilter.alternate:
        return 'Alternate';
      case RecipeFilter.building:
        return 'Buildings';
    }
  }
}