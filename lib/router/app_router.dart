import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/screens/home_screen.dart';
import '../ui/screens/item_browser_screen.dart';
import '../ui/screens/item_detail_screen.dart';
import '../ui/screens/recipe_browser_screen.dart';
import '../ui/screens/recipe_detail_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/shell/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _itemsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'items');
final _recipesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'recipes');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Home branch
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Items branch
        StatefulShellBranch(
          navigatorKey: _itemsNavigatorKey,
          routes: [
            GoRoute(
              path: '/items',
              name: 'items',
              builder: (context, state) => const ItemBrowserScreen(),
              routes: [
                GoRoute(
                  path: ':className',
                  name: 'itemDetail',
                  builder: (context, state) {
                    final className = state.pathParameters['className']!;
                    return ItemDetailScreen(itemClassName: className);
                  },
                ),
              ],
            ),
          ],
        ),

        // Recipes branch
        StatefulShellBranch(
          navigatorKey: _recipesNavigatorKey,
          routes: [
            GoRoute(
              path: '/recipes',
              name: 'recipes',
              builder: (context, state) => const RecipeBrowserScreen(),
              routes: [
                GoRoute(
                  path: ':className',
                  name: 'recipeDetail',
                  builder: (context, state) {
                    final className = state.pathParameters['className']!;
                    return RecipeDetailScreen(recipeClassName: className);
                  },
                ),
              ],
            ),
          ],
        ),

        // Settings branch
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
);
