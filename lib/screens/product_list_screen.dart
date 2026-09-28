import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/product_list/product_list_bloc.dart';
import '../blocs/product_list/product_list_event.dart';
import '../blocs/product_list/product_list_state.dart';
import '../blocs/theme/theme_cubit.dart';
import '../theme/app_theme.dart';
import '../widgets/app_loader.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_product_card.dart';
import 'product_detail_screen.dart';
import '../services/product_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProductListBloc>().add(const ProductListStarted());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductListBloc>().add(const ProductListNextPageRequested());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet(
    ProductListState state, {
    FilterSheetSection section = FilterSheetSection.sort,
  }) async {
    final bloc = context.read<ProductListBloc>();
    final result = await showModalBottomSheet<ProductListFiltersApplied>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        initialSort: state.sortBy,
        initialCategory: state.selectedCategory,
        availableCategories: state.categories,
        countResults: (category) => ProductService().countProducts(
          query: state.searchQuery,
          category: category,
        ),
        initialSection: section,
      ),
    );
    if (result != null) {
      bloc.add(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DISCOVER',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Products',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      BlocBuilder<ThemeCubit, ThemeMode>(
                        builder: (context, mode) {
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context.read<ThemeCubit>().setMode(
                              isDark ? ThemeMode.light : ThemeMode.dark,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: scheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: scheme.cardBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: scheme.cardShadow,
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                color: scheme.primary,
                                size: 22,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                context.read<ProductListBloc>().add(
                                  const ProductListSearchChanged(''),
                                );
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {});
                      context.read<ProductListBloc>().add(
                        ProductListSearchChanged(value),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: BlocBuilder<ProductListBloc, ProductListState>(
                    builder: (context, state) {
                      if (state.status == ProductListStatus.loading) {
                        return GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.66,
                              ),
                          itemCount: 6,
                          itemBuilder: (context, index) =>
                              const SkeletonProductCard(),
                        );
                      }

                      if (state.status == ProductListStatus.failure &&
                          state.products.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.wifi_off_rounded,
                                size: 42,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.errorMessage ?? 'Something went wrong',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => context
                                    .read<ProductListBloc>()
                                    .add(const ProductListRefreshed()),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final visibleProducts = state.visibleProducts;

                      if (visibleProducts.isEmpty) {
                        if (state.hasActiveFilters && !state.hasReachedMax) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            context.read<ProductListBloc>().add(
                              const ProductListNextPageRequested(),
                            );
                          });
                        }
                        return Center(
                          child: state.hasActiveFilters && !state.hasReachedMax
                              ? const AppLoader()
                              : Text(
                                  'No products found',
                                  style: theme.textTheme.bodyLarge,
                                ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<ProductListBloc>().add(
                            const ProductListRefreshed(),
                          );
                          await Future<void>.delayed(
                            const Duration(milliseconds: 600),
                          );
                        },
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                      childAspectRatio: 0.66,
                                    ),
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final product = visibleProducts[index];
                                  return ProductCard(
                                    product: product,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailScreen(
                                            productId: product.id,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }, childCount: visibleProducts.length),
                              ),
                            ),
                            if (!state.hasReachedMax)
                              SliverLayoutBuilder(
                                builder: (context, constraints) {
                                  if (constraints.remainingPaintExtent > 0 &&
                                      state.status ==
                                          ProductListStatus.success) {
                                    WidgetsBinding.instance.addPostFrameCallback(
                                      (_) {
                                        if (!mounted) return;
                                        context.read<ProductListBloc>().add(
                                          const ProductListNextPageRequested(),
                                        );
                                      },
                                    );
                                  }
                                  return SliverToBoxAdapter(
                                    child: SizedBox(
                                      height: 70,
                                      child:
                                          state.status ==
                                              ProductListStatus.loadingMore
                                          ? const Center(child: AppLoader())
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 90),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Center(
                  child: BlocBuilder<ProductListBloc, ProductListState>(
                    buildWhen: (previous, current) =>
                        previous.selectedCategory != current.selectedCategory ||
                        previous.categories != current.categories ||
                        previous.sortBy != current.sortBy ||
                        previous.products != current.products,
                    builder: (context, state) {
                      final sortActive =
                          state.sortBy != ProductSortOption.relevance;
                      final filterCount = state.selectedCategory == null
                          ? 0
                          : 1;

                      return Container(
                        decoration: BoxDecoration(
                          color: scheme.toolbarBackground,
                          border: Border.all(
                            color: scheme.brightness == Brightness.dark
                                ? scheme.cardBorder
                                : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.brightness == Brightness.dark
                                  ? Colors.black.withValues(alpha: 0.24)
                                  : scheme.primary.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Material(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _FloatingBarSegment(
                                icon: Icons.swap_vert_rounded,
                                label: 'Sort',
                                badgeCount: sortActive ? 1 : 0,
                                onTap: () => _openFilterSheet(
                                  state,
                                  section: FilterSheetSection.sort,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 26,
                                color: scheme.toolbarForeground.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                              _FloatingBarSegment(
                                icon: Icons.tune_rounded,
                                label: 'Filter',
                                badgeCount: filterCount,
                                onTap: () => _openFilterSheet(
                                  state,
                                  section: FilterSheetSection.category,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

class _FloatingBarSegment extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badgeCount;
  final VoidCallback onTap;

  const _FloatingBarSegment({
    required this.icon,
    required this.label,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: theme.colorScheme.toolbarForeground),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.toolbarForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.toolbarForeground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    color: theme.colorScheme.toolbarBackground,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
