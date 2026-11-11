
import 'package:el_nada_market/features/products/data/models/product_data.dart';
import 'package:flutter/material.dart';


import 'product_category_screen.dart';

class FruitsScreen extends StatelessWidget {
  final VoidCallback? onHome;

  const FruitsScreen({
    super.key,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return ProductCategoryScreen(
      title: 'فواكه',
      products: ProductData.fruits,
      onHome: onHome,
    );
  }
}
