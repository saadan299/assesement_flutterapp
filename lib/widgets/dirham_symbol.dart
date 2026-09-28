import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DirhamSymbol extends StatelessWidget {
  final double size;
  final Color? color;

  const DirhamSymbol({super.key, required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final tint = color ?? DefaultTextStyle.of(context).style.color;
    return SvgPicture.asset(
      'assets/icons/dirham_symbol.svg',
      width: size,
      height: size * (870 / 1000),
      colorFilter: tint != null
          ? ColorFilter.mode(tint, BlendMode.srcIn)
          : null,
    );
  }
}
