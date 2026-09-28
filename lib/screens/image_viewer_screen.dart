import 'package:flutter/material.dart';
import '../widgets/safe_network_image.dart';
import '../theme/app_theme.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;
  bool _isZoomed = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            physics: _isZoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              return _ZoomableImage(
                imageUrl: widget.images[index],
                onZoomChanged: (zoomed) {
                  if (zoomed != _isZoomed) {
                    setState(() => _isZoomed = zoomed);
                  }
                },
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  if (widget.images.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_index + 1} / ${widget.images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!_isZoomed)
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pinch or double-tap to zoom',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  final String imageUrl;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableImage({required this.imageUrl, required this.onZoomChanged});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  Animation<Matrix4>? _animation;

  static const double _zoomScale = 2.6;

  @override
  void dispose() {
    _animController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(Matrix4 end) {
    _animation = Matrix4Tween(begin: _controller.value, end: end).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    )..addListener(() => _controller.value = _animation!.value);
    _animController.forward(from: 0);
  }

  void _onDoubleTapDown(TapDownDetails details) {
    if (_controller.value != Matrix4.identity()) {
      _animateTo(Matrix4.identity());
      widget.onZoomChanged(false);
      return;
    }

    final position = details.localPosition;
    final end = Matrix4.identity()
      ..translateByDouble(
        -position.dx * (_zoomScale - 1),
        -position.dy * (_zoomScale - 1),
        0,
        1,
      )
      ..scaleByDouble(_zoomScale, _zoomScale, _zoomScale, 1);
    _animateTo(end);
    widget.onZoomChanged(true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: () {},
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1,
        maxScale: 5,
        onInteractionEnd: (_) {
          final scale = _controller.value.getMaxScaleOnAxis();
          widget.onZoomChanged(scale > 1.01);
        },
        child: Center(
          child: SafeNetworkImage(
            imageUrl: widget.imageUrl,
            fit: BoxFit.contain,
            iconSize: 48,
          ),
        ),
      ),
    );
  }
}
