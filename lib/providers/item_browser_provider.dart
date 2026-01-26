import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'game_data_provider.dart';

enum ItemFilter { all, solid, liquid, gas }

enum ItemViewMode { grid, list }

enum ItemSortMode {
  nameAsc,
  nameDesc,
  stackSizeDesc,
  sinkPointsDesc,
  energyDesc,
  radioactivityDesc,
}

final itemSearchQueryProvider = StateProvider<String>((ref) => '');

final itemFilterProvider = StateProvider<ItemFilter>((ref) => ItemFilter.all);

final itemSortModeProvider = StateProvider<ItemSortMode>(
  (ref) => ItemSortMode.nameAsc,
);

final itemViewModeProvider = StateProvider<ItemViewMode>(
  (ref) => ItemViewMode.grid,
);

final filteredItemsProvider = Provider<List<GameItem>>((ref) {
  final itemsMap = ref.watch(allItemsProvider);
  final query = ref.watch(itemSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(itemFilterProvider);
  final sortMode = ref.watch(itemSortModeProvider);

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

  // Sort
  int compareByName(GameItem a, GameItem b) => a.name.compareTo(b.name);
  int compareNumeric(
    num Function(GameItem item) valueOf,
    GameItem a,
    GameItem b,
  ) {
    final compare = valueOf(b).compareTo(valueOf(a));
    if (compare != 0) return compare;
    return compareByName(a, b);
  }

  switch (sortMode) {
    case ItemSortMode.nameAsc:
      items.sort(compareByName);
      break;
    case ItemSortMode.nameDesc:
      items.sort((a, b) => b.name.compareTo(a.name));
      break;
    case ItemSortMode.stackSizeDesc:
      items.sort((a, b) => compareNumeric((item) => item.stackSize, a, b));
      break;
    case ItemSortMode.sinkPointsDesc:
      items.sort((a, b) => compareNumeric((item) => item.sinkPoints, a, b));
      break;
    case ItemSortMode.energyDesc:
      items.sort((a, b) => compareNumeric((item) => item.energy, a, b));
      break;
    case ItemSortMode.radioactivityDesc:
      items.sort(
        (a, b) => compareNumeric((item) => item.radioactive, a, b),
      );
      break;
  }

  return items;
});
