import 'package:flutter/material.dart';

/// A reusable section widget with a title and child content.
class ContentSection extends StatelessWidget {
  final String title;
  final Widget child;

  const ContentSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// Formats a number for display, removing unnecessary trailing zeros.
String formatNumber(double value) {
  if (value.isNaN || value.isInfinite) return '0';
  final absValue = value.abs();
  final decimals = absValue >= 100
      ? 0
      : absValue >= 1
          ? 2
          : 3;
  final text = value.toStringAsFixed(decimals);
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}
