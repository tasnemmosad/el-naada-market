import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:el_nada_market/features/products/data/models/product_model.dart';
import 'package:el_nada_market/features/cart/data/data_sources/cart_remote_data_source.dart';

import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRemoteDataSource remoteDataSource;

  CartCubit(this.remoteDataSource) : super(CartInitial());

  final Map<int, ProductModel> _products = {};
  final Map<int, double> _quantities = {};

  static const double quantityStep = 0.25;

  Future<void> loadBasket() async {
    final items = await remoteDataSource.getBasket();

    _products.clear();
    _quantities.clear();

    for (final item in items) {
      final productJson = Map<String, dynamic>.from(item);

      productJson['id'] = item['product_id'];

      final product = ProductModel.fromJson(productJson);
      final quantity = double.parse(item['quantity'].toString());

      if (quantity <= 0) continue;

      _products[product.id] = product;
      _quantities[product.id] = quantity;
    }

    _emitUpdated();
  }

  Future<void> increase(ProductModel product) async {
    final currentQuantity = _quantities[product.id] ?? 0.0;
    final newQuantity = currentQuantity + quantityStep;

    await remoteDataSource.updateQuantity(
      productId: product.id,
      quantity: newQuantity,
    );

    _products[product.id] = product;
    _quantities[product.id] = newQuantity;

    _emitUpdated();
  }

  Future<void> decrease(int productId) async {
    final currentQuantity = _quantities[productId] ?? 0.0;

    if (currentQuantity <= 0) return;

    final newQuantity = currentQuantity - quantityStep;

    if (newQuantity <= 0) {
      await remoteDataSource.removeProduct(productId);

      _quantities.remove(productId);
      _products.remove(productId);
    } else {
      await remoteDataSource.updateQuantity(
        productId: productId,
        quantity: newQuantity,
      );

      _quantities[productId] = newQuantity;
    }

    _emitUpdated();
  }

  Future<void> removeProduct(int productId) async {
    await remoteDataSource.removeProduct(productId);

    _quantities.remove(productId);
    _products.remove(productId);

    _emitUpdated();
  }

  Future<void> clearCart() async {
    await remoteDataSource.clearBasket();

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

  void clearLocalCart() {
    _quantities.clear();
    _products.clear();
    emit(CartInitial());
  }

  Future<Map<String, dynamic>> createOrder({
    required String deliveryType,
    required String paymentMethod,
  }) async {
    final response = await remoteDataSource.createOrder(
      deliveryType: deliveryType,
      paymentMethod: paymentMethod,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'فشل إنشاء الطلب');
    }

    _quantities.clear();
    _products.clear();
    emit(CartInitial());

    return Map<String, dynamic>.from(response['order'] as Map);
  }
}
