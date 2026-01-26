import 'package:flutter/material.dart';

import '../../logging/app_logger.dart';
import '../../models/models.dart';

class ItemImage extends StatelessWidget {
  final RecipeItem item;
  final double size;

  const ItemImage({super.key, required this.item, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        item.imagePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          appLogger.w(
            'Missing asset image: ${item.imagePath} (item: ${item.name}, class: ${item.className})',
            error: error,
            stackTrace: stackTrace,
          );
          return _FallbackIcon(item: item, size: size);
        },
      ),
    );
  }
}

class GameItemImage extends StatelessWidget {
  final GameItem item;
  final double size;

  const GameItemImage({super.key, required this.item, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        item.imagePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          appLogger.w(
            'Missing asset image: ${item.imagePath} (item: ${item.name}, class: ${item.className})',
            error: error,
            stackTrace: stackTrace,
          );
          return _FallbackIconForGameItem(item: item, size: size);
        },
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final RecipeItem item;
  final double size;

  const _FallbackIcon({required this.item, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (item.isFluid) {
      return Icon(
        Icons.water_drop,
        size: size * 0.7,
        color: _parseColor(item.itemData?.fluidColor),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.inventory_2,
        size: size * 0.6,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }
}

class _FallbackIconForGameItem extends StatelessWidget {
  final GameItem item;
  final double size;

  const _FallbackIconForGameItem({required this.item, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (item.isFluid) {
      return Icon(
        Icons.water_drop,
        size: size * 0.7,
        color: _parseColor(item.fluidColor),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.inventory_2,
        size: size * 0.6,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blue;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.blue;
    }
  }
}
