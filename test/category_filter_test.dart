import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_assessment_app/blocs/product_list/product_list_bloc.dart';
import 'package:product_assessment_app/blocs/product_list/product_list_event.dart';
import 'package:product_assessment_app/blocs/product_list/product_list_state.dart';
import 'package:product_assessment_app/models/product.dart';
import 'package:product_assessment_app/services/product_service.dart';
import 'package:product_assessment_app/widgets/filter_sheet.dart';

Product product(int id, String category) =>
    Product.fromJson({'id': id, 'title': 'Product $id', 'category': category});

ProductListResponse page(
  List<Product> products, {
  int total = 2,
  int skip = 0,
}) => ProductListResponse(
  products: products,
  total: total,
  skip: skip,
  limit: 20,
);

class TestProductService extends ProductService {
  final calls = <String>[];
  Completer<ProductListResponse>? delayedBeauty;

  @override
  Future<List<String>> fetchCategories() async => ['beauty', 'furniture'];

  @override
  Future<ProductListResponse> fetchProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    calls.add('all:$skip');
    return page([product(1, 'beauty'), product(2, 'furniture')]);
  }

  @override
  Future<ProductListResponse> fetchProductsByCategory(
    String category, {
    int limit = 20,
    int skip = 0,
  }) async {
    calls.add('$category:$skip');
    if (category == 'beauty' && delayedBeauty != null) {
      return delayedBeauty!.future;
    }
    return page([product(skip + 10, category)], skip: skip);
  }

  @override
  Future<ProductListResponse> searchProducts(
    String query, {
    int limit = 20,
    int skip = 0,
  }) async {
    calls.add('search:$query:$skip');
    return page([product(1, 'beauty'), product(2, 'furniture')]);
  }
}

Future<void> dispatch(ProductListBloc bloc, ProductListEvent event) async {
  final loaded = bloc.stream.firstWhere(
    (s) => s.status == ProductListStatus.success,
  );
  bloc.add(event);
  await loaded.timeout(const Duration(seconds: 3));
}

class PaginatedSearchService extends TestProductService {
  @override
  Future<ProductListResponse> searchProducts(
    String query, {
    int limit = 20,
    int skip = 0,
  }) async {
    calls.add('search:$query:$skip');
    return skip == 0
        ? page([product(1, 'beauty'), product(2, 'furniture')], total: 3)
        : page([product(3, 'furniture')], total: 3, skip: skip);
  }
}

void main() {
  test('result count uses API totals rather than loaded page length', () async {
    final service = TestProductService();
    expect(await service.countProducts(category: 'furniture'), 2);
    expect(await service.countProducts(), 2);
  });

  test('result count combines search and category across all pages', () async {
    final service = PaginatedSearchService();
    expect(
      await service.countProducts(query: 'product', category: 'furniture'),
      2,
    );
    expect(service.calls, ['search:product:0', 'search:product:2']);
    expect(
      await service.countProducts(query: 'product', category: 'missing'),
      0,
    );
  });

  test(
    'category application resets pages, paginates, and clears to all',
    () async {
      final service = TestProductService();
      final bloc = ProductListBloc(productService: service);
      addTearDown(bloc.close);
      await dispatch(bloc, const ProductListStarted());
      await dispatch(
        bloc,
        const ProductListFiltersApplied(
          sortBy: ProductSortOption.relevance,
          category: 'furniture',
        ),
      );
      expect(bloc.state.selectedCategory, 'furniture');
      expect(bloc.state.products.map((p) => p.category), ['furniture']);
      expect(bloc.state.hasActiveFilters, isTrue);
      await dispatch(bloc, const ProductListNextPageRequested());
      expect(
        service.calls,
        containsAllInOrder(['all:0', 'furniture:0', 'furniture:1']),
      );
      expect(bloc.state.hasReachedMax, isTrue);
      await dispatch(
        bloc,
        const ProductListFiltersApplied(sortBy: ProductSortOption.relevance),
      );
      expect(bloc.state.selectedCategory, isNull);
      expect(bloc.state.hasActiveFilters, isFalse);
      expect(bloc.state.products.length, 2);
      expect(service.calls.last, 'all:0');
    },
  );

  test(
    'search and category combine without losing the API pagination offset',
    () async {
      final service = TestProductService();
      final bloc = ProductListBloc(productService: service);
      addTearDown(bloc.close);
      await dispatch(bloc, const ProductListSearchChanged('product'));
      await dispatch(
        bloc,
        const ProductListFiltersApplied(
          sortBy: ProductSortOption.relevance,
          category: 'furniture',
        ),
      );
      expect(bloc.state.searchQuery, 'product');
      expect(bloc.state.visibleProducts.map((p) => p.category), ['furniture']);
      expect(bloc.state.skip, 2);
      expect(service.calls.last, 'search:product:0');
    },
  );

  test(
    'a delayed previous category cannot replace the latest category',
    () async {
      final service = TestProductService()
        ..delayedBeauty = Completer<ProductListResponse>();
      final bloc = ProductListBloc(productService: service);
      addTearDown(bloc.close);
      final loading = bloc.stream.firstWhere(
        (s) => s.selectedCategory == 'beauty',
      );
      bloc.add(
        const ProductListFiltersApplied(
          sortBy: ProductSortOption.relevance,
          category: 'beauty',
        ),
      );
      await loading;
      await dispatch(
        bloc,
        const ProductListFiltersApplied(
          sortBy: ProductSortOption.relevance,
          category: 'furniture',
        ),
      );
      service.delayedBeauty!.complete(page([product(99, 'beauty')]));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.selectedCategory, 'furniture');
      expect(bloc.state.products.single.category, 'furniture');
    },
  );

  Future<void> openSheet(
    WidgetTester tester,
    ValueChanged<ProductListFiltersApplied?> result, {
    String? initialCategory,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  result(
                    await showModalBottomSheet<ProductListFiltersApplied>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => FilterSheet(
                        initialSort: ProductSortOption.relevance,
                        initialCategory: initialCategory,
                        countResults: (category) async =>
                            category == null ? 30 : 10,
                        availableCategories: const [
                          'beauty',
                          'home-decoration',
                        ],
                        initialSection: FilterSheetSection.category,
                      ),
                    ),
                  );
                },
                child: const Text('Open filters'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();
  }

  testWidgets('category choices are staged and returned on Show results', (
    tester,
  ) async {
    ProductListFiltersApplied? applied;
    await openSheet(tester, (result) => applied = result);
    expect(find.text('Show results (30)'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('All Categories'), findsOneWidget);
    await tester.tap(find.text('Home Decoration'));
    await tester.pumpAndSettle();
    expect(applied, isNull);
    expect(find.text('Show results (10)'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Show results (10)'));
    await tester.pumpAndSettle();
    expect(applied!.category, 'home-decoration');
  });

  testWidgets('Clear All removes an existing category', (tester) async {
    ProductListFiltersApplied? applied;
    await openSheet(
      tester,
      (result) => applied = result,
      initialCategory: 'beauty',
    );
    await tester.tap(find.text('Clear All'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Show results (30)'));
    await tester.pumpAndSettle();
    expect(applied, isNotNull);
    expect(applied!.category, isNull);
  });

  testWidgets('closing without applying discards category changes', (
    tester,
  ) async {
    ProductListFiltersApplied? applied;
    await openSheet(
      tester,
      (result) => applied = result,
      initialCategory: 'beauty',
    );
    await tester.tap(find.text('Home Decoration'));
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(applied, isNull);
  });
}
