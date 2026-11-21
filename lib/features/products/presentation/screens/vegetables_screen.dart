import 'package:flutter/material.dart';
import 'product_category_screen.dart';

class VegetablesScreen extends StatelessWidget {
  final VoidCallback? onHome;

  const VegetablesScreen({super.key, this.onHome});

  @override
  Widget build(BuildContext context) {
    return ProductCategoryScreen(
      title: 'خضروات',
      category: 'vegetable',
      onHome: onHome,
    );
  }
}
