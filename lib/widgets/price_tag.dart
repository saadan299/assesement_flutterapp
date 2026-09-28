import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';
import 'dirham_symbol.dart';

class PriceTag extends StatelessWidget {
  final double price;
  final TextStyle? style;
  final Color? symbolColor;

  const PriceTag({
    super.key,
    required this.price,
    this.style,
    this.symbolColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = style ?? DefaultTextStyle.of(context).style;
    final fontSize = resolvedStyle.fontSize ?? 14;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        DirhamSymbol(
          size: fontSize * 0.92,
          color: symbolColor ?? resolvedStyle.color,
        ),
        SizedBox(width: fontSize * 0.18),
        Flexible(
          child: Text(
            CurrencyFormatter.formatAmount(price),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: resolvedStyle,
          ),
        ),
      ],
    );
  }
}
