import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const List<String> kHeaderBackgrounds = [
  'assets/ui/Abyss_Cliffs.webp',
  'assets/ui/Blue_Crater.webp',
  'assets/ui/Crater_Lakes.webp',
  'assets/ui/Desert_Canyons.webp',
  'assets/ui/Dune_Desert_Area.webp',
  'assets/ui/Eastern_Dune_Forest.webp',
  'assets/ui/Jungle_Spires.webp',
  'assets/ui/Lake_Forest.webp',
  'assets/ui/Maze_Canyons.webp',
  'assets/ui/Northern_Forest.webp',
  'assets/ui/Red_Bamboo_Fields.webp',
  'assets/ui/Red_Jungle.webp',
  'assets/ui/Rocky_Desert_Area.webp',
  'assets/ui/Snaketree_Forest.webp',
  'assets/ui/Southern_Forest.webp',
  'assets/ui/Spire_Coast.webp',
  'assets/ui/Sunrise.webp',
  'assets/ui/Titan_Forest.webp',
  'assets/ui/Western_Beaches.webp',
];

String pickHeaderBackground(String seed) {
  var hash = 0;
  for (final unit in seed.codeUnits) {
    hash = 0x1fffffff & (hash + unit);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash ^= (hash >> 6);
  }
  hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
  hash ^= (hash >> 11);
  hash = 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  final index = hash.abs() % kHeaderBackgrounds.length;
  return kHeaderBackgrounds[index];
}

String pickRandomHeaderBackground() {
  final random = Random();
  final index = random.nextInt(kHeaderBackgrounds.length);
  return kHeaderBackgrounds[index];
}

class HeaderBackground extends StatelessWidget {
  final String imagePath;
  final Widget child;
  final BoxFit fit;
  final Alignment alignment;

  const HeaderBackground({
    super.key,
    required this.imagePath,
    required this.child,
    this.fit = BoxFit.fitWidth,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: fit,
          alignment: alignment,
          filterQuality: FilterQuality.high,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.05),
                AppColors.background.withValues(alpha: 0.35),
                AppColors.background,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: DefaultTextStyle.merge(
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
