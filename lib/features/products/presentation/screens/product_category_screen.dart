
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:el_nada_market/core/theme/app_colors.dart';
import 'package:el_nada_market/features/cart/manager/cart_cubit.dart';
import 'package:el_nada_market/features/cart/manager/cart_state.dart';
import 'package:el_nada_market/features/cart/presentation/cart_screen.dart';

import '../../data/models/product_model.dart';
import '../widgets/product_card.dart';

class ProductCategoryScreen extends StatelessWidget {
  final String title;
  final List<ProductModel> products;
  final VoidCallback? onHome;

  const ProductCategoryScreen({
    super.key,
    required this.title,
    required this.products,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Home Button
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: onHome ??
                        () => Navigator.maybePop(context),
                    icon: const Icon(
                      Icons.arrow_forward,
                      size: 18,
                    ),
                    label: const Text('الرئيسية'),
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

                const SizedBox(height: 16),

                // Category Title
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),

                const SizedBox(height: 14),

                // Products List
                Expanded(
                  child: ListView.separated(
                    physics: const ClampingScrollPhysics(),
                    itemCount: products.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return BlocBuilder<CartCubit, CartState>(
                        buildWhen: (previous, current) {
                          final previousQuantity =
                              previous is CartUpdated
                                  ? previous.quantities[product.id] ?? 0
                                  : 0;

                          final currentQuantity =
                              current is CartUpdated
                                  ? current.quantities[product.id] ?? 0
                                  : 0;

                          return previousQuantity != currentQuantity;
                        },
                        builder: (context, state) {
                          final quantity = state is CartUpdated
                              ? state.quantities[product.id] ?? 0
                              : 0;

                          return ProductCard(
                            key: ValueKey(product.id),
                            product: product,
                            quantity: quantity,
                            onIncrease: () {
                              context
                                  .read<CartCubit>()
                                  .increase(product);
                            },
                            onDecrease: () {
                              context
                                  .read<CartCubit>()
                                  .decrease(product.id);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Show Cart Button
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    final count = state is CartUpdated
                        ? state.totalQuantity
                        : 0;

                    return SizedBox(
                      height: 64,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: count == 0
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const CartScreen(),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.border,
                          disabledForegroundColor:
                              AppColors.textSecondary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'عرض سلتي ($count)',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
