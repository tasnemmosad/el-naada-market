
import 'package:el_nada_market/features/products/data/models/product_data.dart';
import 'package:flutter/material.dart';
import 'product_category_screen.dart';

class VegetablesScreen extends StatelessWidget {
  final VoidCallback? onHome;

  const VegetablesScreen({
    super.key,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return ProductCategoryScreen(
      title: 'خضروات',
      products: ProductData.vegetables,
      onHome: onHome,
    );
  }
}
