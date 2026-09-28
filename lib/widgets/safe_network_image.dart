import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'app_loader.dart';

class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double iconSize;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    if (url == null || url.isEmpty) {
      return _placeholder(color);
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) =>
          Center(child: AppLoader(size: iconSize * 0.7, strokeWidth: 2)),
      errorWidget: (context, url, error) => _placeholder(color),
    );
  }

  Widget _placeholder(Color color) {
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: color,
        size: iconSize,
      ),
    );
  }
}
