
import 'package:el_nada_market/features/products/data/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial());

  final Map<String, ProductModel> _products = {};
  final Map<String, int> _quantities = {};

  void increase(ProductModel product) {
    _products[product.id] = product;

    _quantities[product.id] =
        (_quantities[product.id] ?? 0) + 1;

    _emitUpdated();
  }

  void decrease(String productId) {
    final currentQuantity = _quantities[productId] ?? 0;

    if (currentQuantity <= 0) return;

    if (currentQuantity == 1) {
      _quantities.remove(productId);
      _products.remove(productId);
    } else {
      _quantities[productId] = currentQuantity - 1;
    }

    _emitUpdated();
  }

  void removeProduct(String productId) {
    _quantities.remove(productId);
    _products.remove(productId);

    _emitUpdated();
  }

  void clearCart() {
    _quantities.clear();
    _products.clear();

    emit(CartInitial());
  }

  void _emitUpdated() {
    emit(
      CartUpdated(
        quantities: Map.unmodifiable(_quantities),
        products: List.unmodifiable(_products.values),
      ),
    );
  }
}
