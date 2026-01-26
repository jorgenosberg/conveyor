import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../theme/app_theme.dart';
import 'item_image.dart';

/// Compact card for grid view - shows image and name.
class ItemGridCard extends StatelessWidget {
  final GameItem item;
  final VoidCallback? onTap;

  const ItemGridCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.borderLight),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GameItemImage(item: item, size: 48),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// List item card with more details - shows image, name, description, and form badge.
class ItemListCard extends StatelessWidget {
  final GameItem item;
  final VoidCallback? onTap;

  const ItemListCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          border: Border(bottom: BorderSide(color: AppColors.borderLight)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            GameItemImage(item: item, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (item.description.isNotEmpty)
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _FormBadge(form: item.form),
          ],
        ),
      ),
    );
  }
}

class _FormBadge extends StatelessWidget {
  final ItemForm form;

  const _FormBadge({required this.form});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (form) {
      ItemForm.solid => ('Solid', AppColors.textSecondary),
      ItemForm.liquid => ('Liquid', Colors.blue),
      ItemForm.gas => ('Gas', Colors.purple),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
