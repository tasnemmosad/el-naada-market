
import 'package:flutter/material.dart';
import 'package:el_nada_market/core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import 'quantity_selector.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child:
Row(
  textDirection: TextDirection.rtl,
  children: [
    // Product Image - Right
    ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        product.imageUrl,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        cacheWidth: 126,
        cacheHeight: 126,
        errorBuilder: (_, _, _) => Container(
          width: 42,
          height: 42,
          color: product.color,
        ),
      ),
    ),

    const SizedBox(width: 7),

    // Product Information
    SizedBox(
      width: 62,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${product.pricePerKg.toStringAsFixed(0)} جنيه',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const Text(
            'للكيلو',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),

    const Spacer(),

    // Quantity Controls - Left
    QuantitySelector(
      quantity: quantity,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
    ),
  ],
)

    );
  }
}
