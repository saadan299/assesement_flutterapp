import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StockBadge extends StatelessWidget {
  final bool isInStock;
  final String label;
  final bool compact;

  const StockBadge({
    super.key,
    required this.isInStock,
    required this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = isInStock
        ? scheme.successForeground
        : scheme.dangerForeground;
    final background = isInStock ? scheme.successBg : scheme.dangerBg;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 11,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 7,
            height: compact ? 6 : 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: compact ? 5 : 6),
          Text(
            label,
            style:
                (compact
                        ? theme.textTheme.labelSmall
                        : theme.textTheme.labelMedium)
                    ?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
          ),
        ],
      ),
    );
  }
}
