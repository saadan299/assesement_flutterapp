import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/product_detail/product_detail_bloc.dart';
import '../blocs/product_detail/product_detail_event.dart';
import '../blocs/product_detail/product_detail_state.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/price_tag.dart';
import '../widgets/safe_network_image.dart';
import '../widgets/skeleton_product_detail.dart';
import '../widgets/stock_badge.dart';
import 'image_viewer_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProductDetailBloc()..add(ProductDetailRequested(productId)),
      child: const _ProductDetailView(),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  const _ProductDetailView();

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  final _pageController = PageController();
  int _currentImage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToImage(int index) {
    setState(() => _currentImage = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _openImageViewer(BuildContext context, List<String> images) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ImageViewerScreen(images: images, initialIndex: _currentImage),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
        builder: (context, state) {
          if (state.status == ProductDetailStatus.loading ||
              state.status == ProductDetailStatus.initial) {
            return const SkeletonProductDetail();
          }

          if (state.status == ProductDetailStatus.failure ||
              state.product == null) {
            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        isDark: isDark,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 42,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(state.errorMessage ?? 'Failed to load product'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final product = state.product!;
          final images = product.galleryImages.isNotEmpty
              ? product.galleryImages
              : const [''];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 400,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: scheme.imageWellGradient,
                            ),
                          ),
                          PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            onPageChanged: (index) =>
                                setState(() => _currentImage = index),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _openImageViewer(context, images),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    40,
                                    70,
                                    40,
                                    40,
                                  ),
                                  child: SafeNetworkImage(
                                    imageUrl: images[index],
                                    fit: BoxFit.contain,
                                    iconSize: 40,
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            right: 16,
                            bottom: images.length > 1 ? 40 : 16,
                            child: IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.zoom_in_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Tap to zoom',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (images.length > 1)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  images.length,
                                  (index) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: _currentImage == index ? 20 : 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: _currentImage == index
                                          ? scheme.primary
                                          : scheme.primary.withValues(
                                              alpha: 0.25,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _RoundIconButton(
                          icon: Icons.arrow_back_rounded,
                          isDark: isDark,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  transform: Matrix4.translationValues(0, -24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: scheme.cardBorder,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (images.length > 1)
                        _ThumbnailStrip(
                          images: images,
                          selectedIndex: _currentImage,
                          onSelect: _goToImage,
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Pill(
                              label: product.displayBrand.toUpperCase(),
                              background: scheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              foreground: scheme.primary,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.title,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4,
                                          height: 1.15,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: _RatingBadge(rating: product.rating),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: PriceTag(
                                      price: product.price,
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: scheme.primary,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                StockBadge(
                                  isInStock: product.isInStock,
                                  label: product.availabilityStatus,
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            _SectionCard(
                              title: 'Description',
                              child: _ExpandableText(text: product.description),
                            ),
                            if (product.hasQrCode) ...[
                              const SizedBox(height: 16),
                              _SectionCard(
                                title: 'Scan QR Code',
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: scheme.cardBorder,
                                      ),
                                    ),
                                    child: SafeNetworkImage(
                                      imageUrl: product.qrCode,
                                      width: 132,
                                      height: 132,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: 'Reviews',
                              trailing: product.reviews.isEmpty
                                  ? null
                                  : _Pill(
                                      label: '${product.reviews.length}',
                                      background: scheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      foreground: scheme.primary,
                                    ),
                              child: product.reviews.isEmpty
                                  ? Text(
                                      'No reviews yet for this product.',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    )
                                  : Column(
                                      children: [
                                        for (
                                          var i = 0;
                                          i < product.reviews.length;
                                          i++
                                        ) ...[
                                          if (i > 0)
                                            Divider(
                                              height: 24,
                                              color: scheme.cardBorder,
                                            ),
                                          _ReviewTile(
                                            review: product.reviews[i],
                                          ),
                                        ],
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
          size: 20,
        ),
      ),
    );
  }
}

class _ThumbnailStrip extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ThumbnailStrip({
    required this.images,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: scheme.imageWellGradient,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? scheme.primary : scheme.cardBorder,
                  width: selected ? 2 : 1.2,
                ),
              ),
              child: SafeNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.contain,
                iconSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filledStars = rating.round().clamp(0, 5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            5,
            (i) => Icon(
              i < filledStars ? Icons.star_rounded : Icons.star_border_rounded,
              size: 14,
              color: AppColors.rating,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;

  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.5,
    );

    if (widget.text.isEmpty) {
      return Text('No description available.', style: style);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: style);
        final painter = TextPainter(
          text: span,
          maxLines: 3,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);
        final isOverflowing = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: style,
              maxLines: _expanded ? null : 3,
              overflow: _expanded ? null : TextOverflow.ellipsis,
            ),
            if (isOverflowing)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? 'Show less' : 'Read more',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final initial = review.reviewerName.isNotEmpty
        ? review.reviewerName[0].toUpperCase()
        : '?';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: scheme.primary.withValues(alpha: 0.12),
          child: Text(
            initial,
            style: TextStyle(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      review.reviewerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < review.rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 14,
                        color: AppColors.rating,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                review.comment,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
