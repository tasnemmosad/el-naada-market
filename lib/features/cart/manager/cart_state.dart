
import 'package:el_nada_market/features/products/data/models/product_model.dart';



sealed class CartState {}

class CartInitial extends CartState {}

class CartUpdated extends CartState {
  final Map<String, int> quantities;
  final List<ProductModel> products;

  CartUpdated({
    required this.quantities,
    required this.products,
  });

  int get totalQuantity {
    return quantities.values.fold(
      0,
      (sum, quantity) => sum + quantity,
    );
  }

  double get totalPrice {
    double total = 0;

    for (final product in products) {
      total += product.pricePerKg *
          (quantities[product.id] ?? 0);
    }

    return total;
  }
}
