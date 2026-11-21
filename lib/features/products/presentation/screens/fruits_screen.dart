import 'package:flutter/material.dart';
import 'product_category_screen.dart';

class FruitsScreen extends StatelessWidget {
  final VoidCallback? onHome;

  const FruitsScreen({super.key, this.onHome});

  @override
  Widget build(BuildContext context) {
    return ProductCategoryScreen(
      title: 'فواكه',
      category: 'fruit',
      onHome: onHome,
    );
  }
}
