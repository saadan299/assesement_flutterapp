import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const AppLoader({super.key, this.size = 22, this.strokeWidth = 2.4});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: _isApplePlatform
          ? CupertinoActivityIndicator(radius: size / 2, color: color)
          : CircularProgressIndicator(
              color: color,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
            ),
    );
  }

  bool get _isApplePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);
}
