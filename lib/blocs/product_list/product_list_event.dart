import 'package:equatable/equatable.dart';
import 'product_list_state.dart';

abstract class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object?> get props => [];
}

class ProductListStarted extends ProductListEvent {
  const ProductListStarted();
}

class ProductListRefreshed extends ProductListEvent {
  const ProductListRefreshed();
}

class ProductListNextPageRequested extends ProductListEvent {
  const ProductListNextPageRequested();
}

class ProductListSearchChanged extends ProductListEvent {
  final String query;

  const ProductListSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ProductListFiltersApplied extends ProductListEvent {
  final ProductSortOption sortBy;
  final String? category;

  const ProductListFiltersApplied({required this.sortBy, this.category});

  @override
  List<Object?> get props => [sortBy, category];
}
