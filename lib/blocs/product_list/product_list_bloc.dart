import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../services/product_service.dart';
import 'product_list_event.dart';
import 'product_list_state.dart';

const _pageLimit = 10;
const _searchDebounceDuration = Duration(milliseconds: 400);

EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final ProductService _productService;
  int _requestId = 0;

  ProductListBloc({ProductService? productService})
    : _productService = productService ?? ProductService(),
      super(const ProductListState()) {
    on<ProductListStarted>(_onStarted);
    on<ProductListRefreshed>(_onRefreshed);
    on<ProductListNextPageRequested>(_onNextPageRequested);
    on<ProductListSearchChanged>(
      _onSearchChanged,
      transformer: _debounce(_searchDebounceDuration),
    );
    on<ProductListFiltersApplied>(_onFiltersApplied);
  }

  Future<void> _onStarted(
    ProductListStarted event,
    Emitter<ProductListState> emit,
  ) async {
    final requestId = ++_requestId;
    emit(state.copyWith(status: ProductListStatus.loading));
    try {
      final categories = await _productService.fetchCategories();
      final response = await _productService.fetchProducts(
        limit: _pageLimit,
        skip: 0,
      );
      if (emit.isDone || requestId != _requestId) return;
      emit(
        state.copyWith(
          status: ProductListStatus.success,
          products: response.products,
          categories: categories,
          skip: response.products.length,
          hasReachedMax: response.products.length >= response.total,
        ),
      );
    } catch (e) {
      if (emit.isDone || requestId != _requestId) return;
      emit(
        state.copyWith(
          status: ProductListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshed(
    ProductListRefreshed event,
    Emitter<ProductListState> emit,
  ) async {
    emit(state.copyWith(status: ProductListStatus.loading, skip: 0));
    await _load(emit, skip: 0, replace: true);
  }

  Future<void> _onNextPageRequested(
    ProductListNextPageRequested event,
    Emitter<ProductListState> emit,
  ) async {
    if (state.hasReachedMax || state.status != ProductListStatus.success) {
      return;
    }
    emit(state.copyWith(status: ProductListStatus.loadingMore));
    await _load(emit, skip: state.skip, replace: false);
  }

  Future<void> _onSearchChanged(
    ProductListSearchChanged event,
    Emitter<ProductListState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProductListStatus.loading,
        searchQuery: event.query,
        products: const [],
        hasReachedMax: false,
        skip: 0,
      ),
    );
    await _load(emit, skip: 0, replace: true);
  }

  Future<void> _onFiltersApplied(
    ProductListFiltersApplied event,
    Emitter<ProductListState> emit,
  ) async {
    final categoryChanged = event.category != state.selectedCategory;
    emit(
      state.copyWith(
        sortBy: event.sortBy,
        selectedCategory: event.category,
        clearCategory: event.category == null,
        status: categoryChanged ? ProductListStatus.loading : null,
        products: categoryChanged ? const [] : null,
        skip: categoryChanged ? 0 : null,
        hasReachedMax: categoryChanged ? false : null,
      ),
    );
    if (categoryChanged) {
      await _load(emit, skip: 0, replace: true);
    }
  }

  Future<void> _load(
    Emitter<ProductListState> emit, {
    required int skip,
    required bool replace,
  }) async {
    final requestId = ++_requestId;
    final query = state.searchQuery;
    final category = state.selectedCategory;
    try {
      final response = query.isNotEmpty
          ? await _productService.searchProducts(
              query,
              limit: _pageLimit,
              skip: skip,
            )
          : category != null
          ? await _productService.fetchProductsByCategory(
              category,
              limit: _pageLimit,
              skip: skip,
            )
          : await _productService.fetchProducts(limit: _pageLimit, skip: skip);

      if (emit.isDone || requestId != _requestId) return;
      final updated = replace
          ? response.products
          : [...state.products, ...response.products];

      emit(
        state.copyWith(
          status: ProductListStatus.success,
          products: updated,
          skip: updated.length,
          hasReachedMax: updated.length >= response.total,
        ),
      );
    } catch (e) {
      if (emit.isDone || requestId != _requestId) return;
      emit(
        state.copyWith(
          status: ProductListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
