import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/product_service.dart';
import 'product_detail_event.dart';
import 'product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final ProductService _productService;

  ProductDetailBloc({ProductService? productService})
    : _productService = productService ?? ProductService(),
      super(const ProductDetailState()) {
    on<ProductDetailRequested>(_onRequested);
  }

  Future<void> _onRequested(
    ProductDetailRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(state.copyWith(status: ProductDetailStatus.loading));
    try {
      final product = await _productService.fetchProductDetail(event.productId);
      emit(
        state.copyWith(status: ProductDetailStatus.success, product: product),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
