import 'package:flutter/material.dart';
import 'package:el_nada_market/core/theme/app_colors.dart';

import '../../data/models/product_model.dart';
import 'quantity_selector.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final double quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  String _formatNumber(double value) {
    return value.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  String _unitLabel(String unit) {
    switch (unit.toLowerCase()) {
      case 'kg':
        return 'كجم';
      case 'grm':
        return 'جرام';
      case 'piece':
        return 'قطعة';
      case 'carton':
        return 'كرتونة';
      default:
        return unit;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl;

    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),

          const SizedBox(width: 7),

          SizedBox(
            width: 90,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.nameAr.isNotEmpty ? product.nameAr : product.nameEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${_formatNumber(product.unitPrice)} جنيه',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                Text(
                  'لـ ${_unitLabel(product.unitOfMsrSo)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          QuantitySelector(
            quantity: quantity,
            onIncrease: onIncrease,
            onDecrease: onDecrease,
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 42,
      height: 42,
      color: AppColors.surface,
      child: const Icon(
        Icons.shopping_basket_outlined,
        color: AppColors.textSecondary,
      ),
    );
  }
}
