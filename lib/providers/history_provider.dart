import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxRecentItems = 10;

/// Tracks recently viewed item classNames.
class RecentItemsNotifier extends StateNotifier<List<String>> {
  RecentItemsNotifier() : super([]);

  void add(String className) {
    final updated = [
      className,
      ...state.where((c) => c != className),
    ].take(_maxRecentItems).toList();
    state = updated;
  }

  void clear() {
    state = [];
  }
}

/// Tracks recently viewed recipe classNames.
class RecentRecipesNotifier extends StateNotifier<List<String>> {
  RecentRecipesNotifier() : super([]);

  void add(String className) {
    final updated = [
      className,
      ...state.where((c) => c != className),
    ].take(_maxRecentItems).toList();
    state = updated;
  }

  void clear() {
    state = [];
  }
}

final recentItemsProvider =
    StateNotifierProvider<RecentItemsNotifier, List<String>>((ref) {
      return RecentItemsNotifier();
    });

final recentRecipesProvider =
    StateNotifierProvider<RecentRecipesNotifier, List<String>>((ref) {
      return RecentRecipesNotifier();
    });
