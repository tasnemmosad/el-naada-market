

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:el_nada_market/core/theme/app_colors.dart';
import 'package:el_nada_market/features/cart/manager/cart_cubit.dart';
import 'package:el_nada_market/features/cart/manager/cart_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? selectedDelivery;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,

        // Existing Top Bar
        appBar: AppBar(
          title: const Text('سلتي'),
          backgroundColor: AppColors.background,
          centerTitle: true,
        ),

        body: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state is CartInitial ||
                (state is CartUpdated && state.products.isEmpty)) {
              return const Center(
                child: Text(
                  'السلة فارغة',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            if (state is! CartUpdated) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Add More Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_forward,
                        size: 18,
                      ),
                      label: const Text('أضف المزيد'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Cart Title
                  Text(
                    'سلتي',
                    textAlign: TextAlign.right,
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),

                  const SizedBox(height: 16),

                  // Cart Items
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.products.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = state.products[index];

                        final quantity =
                            state.quantities[product.id] ?? 0;

                        final itemTotal =
                            product.pricePerKg * quantity;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              // Product Name
                              Expanded(
                                flex: 2,
                                child: Text(
                                  product.name,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),

                              // Quantity Controls
                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _quantityButton(
                                      icon: Icons.remove,
                                      onPressed: () {
                                        context
                                            .read<CartCubit>()
                                            .decrease(product.id);
                                      },
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                      ),
                                      child: Text(
                                        '$quantity كجم',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),

                                    _quantityButton(
                                      icon: Icons.add,
                                      onPressed: () {
                                        context
                                            .read<CartCubit>()
                                            .increase(product);
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Product Total Price
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${itemTotal.toStringAsFixed(0)} جنيه',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Grand Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الإجمالي',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${state.totalPrice.toStringAsFixed(0)} جنيه',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Delivery Options
                  Row(
                    children: [
                      Expanded(
                        child: _buildDeliveryButton(
                          title: 'سآتي بنفسي',
                          value: 'pickup',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDeliveryButton(
                          title: 'يوصل لي',
                          value: 'delivery',
                        ),
                      ),
                    ],
                  ),

                
const SizedBox(height: 16),

// Send Order Button
SizedBox(
  width: double.infinity,
  height: 64,
  child: ElevatedButton(
    onPressed: () {
      if (selectedDelivery == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('اختاري طريقة الاستلام أولاً'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سيتم إرسال طلبك قريباً'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    child: const Text(
      'أرسل طلبي',
      style: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
),
const SizedBox(height: 12),

                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Quantity Button
  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 30,
      height: 30,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(
            color: AppColors.primaryGreen,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  // Delivery Selection Button
  Widget _buildDeliveryButton({
    required String title,
    required String value,
  }) {
    final isSelected = selectedDelivery == value;

    return SizedBox(
      height: 58,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            selectedDelivery = value;
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.primaryGreen.withValues(alpha: 0.10)
              : AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.border,
            width: isSelected ? 2 : 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
