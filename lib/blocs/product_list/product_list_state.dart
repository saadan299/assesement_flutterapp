import 'package:equatable/equatable.dart';
import '../../models/product.dart';

enum ProductListStatus { initial, loading, success, failure, loadingMore }

enum ProductSortOption {
  relevance,
  priceLowHigh,
  priceHighLow,
  ratingHighLow,
  nameAZ,
}

extension ProductSortOptionLabel on ProductSortOption {
  String get label {
    switch (this) {
      case ProductSortOption.relevance:
        return 'Relevance';
      case ProductSortOption.priceLowHigh:
        return 'Price: Low to High';
      case ProductSortOption.priceHighLow:
        return 'Price: High to Low';
      case ProductSortOption.ratingHighLow:
        return 'Rating: High to Low';
      case ProductSortOption.nameAZ:
        return 'Name: A to Z';
    }
  }
}

class ProductListState extends Equatable {
  final ProductListStatus status;
  final List<Product> products;
  final List<String> categories;
  final String searchQuery;
  final String? selectedCategory;
  final ProductSortOption sortBy;
  final bool hasReachedMax;
  final int skip;
  final String? errorMessage;

  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.sortBy = ProductSortOption.relevance,
    this.hasReachedMax = false,
    this.skip = 0,
    this.errorMessage,
  });

  bool get hasActiveFilters => selectedCategory != null;

  List<Product> get visibleProducts {
    var result = products;

    if (selectedCategory != null) {
      result = result.where((p) => p.category == selectedCategory).toList();
    }

    switch (sortBy) {
      case ProductSortOption.relevance:
        break;
      case ProductSortOption.priceLowHigh:
        result = [...result]..sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceHighLow:
        result = [...result]..sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.ratingHighLow:
        result = [...result]..sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ProductSortOption.nameAZ:
        result = [...result]
          ..sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          );
        break;
    }

    return result;
  }

  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? products,
    List<String>? categories,
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
    ProductSortOption? sortBy,
    bool? hasReachedMax,
    int? skip,
    String? errorMessage,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      sortBy: sortBy ?? this.sortBy,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      skip: skip ?? this.skip,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    categories,
    searchQuery,
    selectedCategory,
    sortBy,
    hasReachedMax,
    skip,
    errorMessage,
  ];
}
