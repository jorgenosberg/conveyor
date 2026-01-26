import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'game_data_provider.dart';

enum ItemFilter { all, solid, liquid, gas }

enum ItemViewMode { grid, list }

final itemSearchQueryProvider = StateProvider<String>((ref) => '');

final itemFilterProvider = StateProvider<ItemFilter>((ref) => ItemFilter.all);

final itemViewModeProvider =
    StateProvider<ItemViewMode>((ref) => ItemViewMode.grid);

final filteredItemsProvider = Provider<List<GameItem>>((ref) {
  final itemsMap = ref.watch(allItemsProvider);
  final query = ref.watch(itemSearchQueryProvider).toLowerCase();
  final filter = ref.watch(itemFilterProvider);

  var items = itemsMap.values.toList();

  // Apply filter
  if (filter != ItemFilter.all) {
    items = items.where((item) {
      switch (filter) {
        case ItemFilter.solid:
          return item.form == ItemForm.solid;
        case ItemFilter.liquid:
          return item.form == ItemForm.liquid;
        case ItemFilter.gas:
          return item.form == ItemForm.gas;
        case ItemFilter.all:
          return true;
      }
    }).toList();
  }

  // Apply search
  if (query.isNotEmpty) {
    items = items.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.className.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
    }).toList();
  }

  // Sort alphabetically
  items.sort((a, b) => a.name.compareTo(b.name));

  return items;
});
