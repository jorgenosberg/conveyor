import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/screens/item_detail_screen.dart';
import '../ui/screens/recipe_browser_screen.dart';
import '../ui/screens/recipe_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'recipes',
      builder: (context, state) => const RecipeBrowserScreen(),
    ),
    GoRoute(
      path: '/recipe/:className',
      name: 'recipeDetail',
      builder: (context, state) {
        final className = state.pathParameters['className']!;
        return RecipeDetailScreen(recipeClassName: className);
      },
    ),
    GoRoute(
      path: '/item/:className',
      name: 'itemDetail',
      builder: (context, state) {
        final className = state.pathParameters['className']!;
        return ItemDetailScreen(itemClassName: className);
      },
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
);
