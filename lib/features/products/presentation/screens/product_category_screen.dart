import 'package:el_nada_market/core/di/set_up_locator.dart';
import 'package:el_nada_market/features/orders/presentation/manager/orders_cubit.dart';
import 'package:el_nada_market/features/products/presentation/manager/products_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:el_nada_market/core/theme/app_colors.dart';
import 'package:el_nada_market/features/cart/manager/cart_cubit.dart';
import 'package:el_nada_market/features/cart/manager/cart_state.dart';
import 'package:el_nada_market/features/cart/presentation/cart_screen.dart';

import '../widgets/product_card.dart';

class ProductCategoryScreen extends StatelessWidget {
  final String title;
  final String category;
  final VoidCallback? onHome;

  const ProductCategoryScreen({
    super.key,
    required this.title,
    required this.category,
    this.onHome,
  });

  String _formatNumber(double value) {
    return value.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
             
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: onHome ?? () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_forward, size: 18),
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

             
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 14),

                // قائمة المنتجات
                Expanded(
                  child: BlocBuilder<ProductsCubit, ProductsState>(
                    builder: (context, productsState) {
                      // حالة تحميل المنتجات
                      if (productsState is ProductsLoading ||
                          productsState is ProductsInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // حالة حدوث خطأ
                      if (productsState is ProductsError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'حصل خطأ أثناء تحميل المنتجات',
                                style: TextStyle(color: AppColors.textPrimary),
                              ),

                              const SizedBox(height: 8),

                              TextButton(
                                onPressed: () {
                                  context.read<ProductsCubit>().getProducts();
                                },
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        );
                      }

                    
                      if (productsState is ProductsLoaded) {
                        final products = productsState.products
                            .where(
                              (product) =>
                                  product.category.trim().toLowerCase() ==
                                  category.trim().toLowerCase(),
                            )
                            .toList();

                        // لا توجد منتجات في القسم
                        if (products.isEmpty) {
                          return const Center(
                            child: Text(
                              'لا توجد منتجات في هذا القسم',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          physics: const ClampingScrollPhysics(),
                          itemCount: products.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final product = products[index];

                            return BlocBuilder<CartCubit, CartState>(
                              builder: (context, cartState) {
                                final double quantity = cartState is CartUpdated
                                    ? cartState.quantities[product.id] ?? 0.0
                                    : 0.0;

                                return ProductCard(
                                  key: ValueKey(product.id),
                                  product: product,
                                  quantity: quantity,

                                  onIncrease: () {
                                    context.read<CartCubit>().increase(product);
                                  },

                            
                                  onDecrease: () {
                                    context.read<CartCubit>().decrease(
                                      product.id,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),

                const SizedBox(height: 12),

             
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    final int itemCount = state is CartUpdated
                        ? state.quantities.values
                              .where((quantity) => quantity > 0)
                              .length
                        : 0;

                    return SizedBox(
                      height: 64,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: itemCount == 0
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) => sl<OrdersCubit>(),
                                      child: const CartScreen(),
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.border,
                          disabledForegroundColor: AppColors.textSecondary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'عرض سلتي ($itemCount )',
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
