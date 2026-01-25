import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'ui/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: ConveyorApp()));
}

class ConveyorApp extends StatelessWidget {
  const ConveyorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Conveyor',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
