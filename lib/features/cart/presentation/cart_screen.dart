
import 'package:el_nada_market/features/orders/presentation/manager/orders_cubit.dart';
import 'package:el_nada_market/features/orders/presentation/manager/orders_state.dart';
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
  String? selectedPayment;
  bool _isSubmitting = false;

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

  String _formatNumber(double value) {
    return value.toStringAsFixed(2).replaceAll(
          RegExp(r'\.?0+$'),
          '',
        );
  }

  Future<void> _submitOrder() async {
    if (_isSubmitting) return;

    if (selectedDelivery == null) {
      _showMessage('اختاري طريقة الاستلام أولاً');
      return;
    }

    if (selectedPayment == null) {
      _showMessage('اختاري طريقة الدفع أولاً');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final ordersCubit = context.read<OrdersCubit>();

      await ordersCubit.createOrder(
        deliveryType: selectedDelivery!,
        paymentMethod: selectedPayment!,
      );

      if (!mounted) return;

      final orderState = ordersCubit.state;

      if (orderState is OrdersError) {
        _showMessage(orderState.message);
        return;
      }

      if (orderState is! OrdersSuccess) {
        _showMessage('لم يتم تأكيد إنشاء الطلب');
        return;
      }

      final order = orderState.order;
      final orderId = order['id'];
      final total = order['total'];

      // السيرفر بيفرغ السلة بعد إنشاء الطلب بنجاح.
      // هنا بنفرغ النسخة المحلية فقط.
      context.read<CartCubit>().clearLocalCart();

      setState(() {
        selectedDelivery = null;
        selectedPayment = null;
      });

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text(
                'تم إرسال طلبك بنجاح',
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 65,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'رقم الطلب: $orderId',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الإجمالي: $total جنيه',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('حسناً'),
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (mounted) {
        ordersCubit.reset();
      }
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () {
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

                  Expanded(
                    child: ListView.separated(
                      itemCount: state.products.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = state.products[index];

                        final quantity =
                            state.quantities[product.id] ?? 0.0;

                        final itemTotal =
                            product.unitPrice * quantity;

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
                              Expanded(
                                flex: 2,
                                child: Text(
                                  product.nameAr,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 3,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    _quantityButton(
                                      icon: Icons.remove,
                                      onPressed: _isSubmitting
                                          ? null
                                          : () {
                                              context
                                                  .read<CartCubit>()
                                                  .decrease(product.id);
                                            },
                                    ),

                                    Flexible(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 7,
                                        ),
                                        child: Text(
                                          '${_formatNumber(quantity)} ${_unitLabel(product.unitOfMsrSo)}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),

                                    _quantityButton(
                                      icon: Icons.add,
                                      onPressed: _isSubmitting
                                          ? null
                                          : () {
                                              context
                                                  .read<CartCubit>()
                                                  .increase(product);
                                            },
                                    ),
                                  ],
                                ),
                              ),

                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${_formatNumber(itemTotal)} جنيه',
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
                        '${_formatNumber(state.totalPrice)} جنيه',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'طريقة الاستلام',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionButton(
                          title: 'سآتي بنفسي',
                          value: 'pickup',
                          selectedValue: selectedDelivery,
                          onSelected: (value) {
                            setState(() {
                              selectedDelivery = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildOptionButton(
                          title: 'يوصل لي',
                          value: 'delivery',
                          selectedValue: selectedDelivery,
                          onSelected: (value) {
                            setState(() {
                              selectedDelivery = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'طريقة الدفع',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildOptionButton(
                          title: 'كاش',
                          value: 'cash',
                          selectedValue: selectedPayment,
                          onSelected: (value) {
                            setState(() {
                              selectedPayment = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildOptionButton(
                          title: 'كارت',
                          value: 'card',
                          selectedValue: selectedPayment,
                          onSelected: (value) {
                            setState(() {
                              selectedPayment = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildOptionButton(
                          title: 'محفظة',
                          value: 'wallet',
                          selectedValue: selectedPayment,
                          onSelected: (value) {
                            setState(() {
                              selectedPayment = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primaryGreen.withValues(
                          alpha: 0.5,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
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

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
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

  Widget _buildOptionButton({
    required String title,
    required String value,
    required String? selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    final isSelected = selectedValue == value;

    return SizedBox(
      height: 55,
      child: OutlinedButton(
        onPressed: _isSubmitting
            ? null
            : () => onSelected(value),
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
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
