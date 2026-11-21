import 'package:el_nada_market/core/di/set_up_locator.dart';
import 'package:el_nada_market/features/orders/presentation/manager/orders_cubit.dart';
import 'package:el_nada_market/features/orders/presentation/manager/orders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:el_nada_market/core/theme/app_colors.dart';

class OrderDetailsScreen extends StatelessWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrdersCubit>()..loadOrderDetails(orderId),
      child: _OrderDetailsView(orderId: orderId),
    );
  }
}

class _OrderDetailsView extends StatelessWidget {
  final int orderId;

  const _OrderDetailsView({required this.orderId});

  String _money(dynamic value) {
    final number = double.tryParse(value.toString()) ?? 0;
    return number.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _delivery(String? value) {
    return value == 'delivery' ? 'توصيل' : 'استلام من المحل';
  }

  String _payment(String? value) {
    switch (value) {
      case 'cash':
        return 'كاش';
      case 'card':
        return 'كارت';
      case 'wallet':
        return 'محفظة إلكترونية';
      default:
        return value ?? 'غير معروف';
    }
  }

  String _status(String? value) {
    switch (value) {
      case 'new':
        return 'جديد';
      case 'confirmed':
        return 'تم التأكيد';
      case 'preparing':
        return 'جاري التجهيز';
      case 'ready':
        return 'جاهز';
      case 'delivered':
        return 'تم التوصيل';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return value ?? 'غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('تفاصيل الطلب #$orderId'),
          centerTitle: true,
          backgroundColor: AppColors.background,
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is OrderDetailsLoading || state is OrdersInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            if (state is OrdersError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<OrdersCubit>().loadOrderDetails(orderId);
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is! OrderDetailsLoaded) {
              return const SizedBox.shrink();
            }

            final order = state.order;

            final items = (order['items'] as List<dynamic>? ?? const []);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _section(
                  title: 'بيانات الطلب',
                  children: [
                    _infoRow('رقم الطلب', '#${order['id']}'),
                    _infoRow('الحالة', _status(order['status']?.toString())),
                    _infoRow(
                      'طريقة الاستلام',
                      _delivery(order['delivery_type']?.toString()),
                    ),
                    _infoRow(
                      'طريقة الدفع',
                      _payment(order['payment_method']?.toString()),
                    ),
                    if (order['delivery_type'] == 'delivery')
                      _infoRow(
                        'عنوان التوصيل',
                        order['delivery_address']?.toString() ?? 'غير متاح',
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                _section(
                  title: 'المنتجات',
                  children: [
                    for (final item in items)
                      if (item is Map)
                        _productRow(
                          name: item['product_name']?.toString() ?? '',
                          quantity: _money(item['quantity']),
                          unitPrice: _money(item['unit_price']),
                          subtotal: _money(item['subtotal']),
                        ),
                  ],
                ),

                const SizedBox(height: 16),

                _section(
                  title: 'الإجمالي النهائي',
                  children: [
                    _infoRow(
                      'الإجمالي',
                      '${_money(order['total'])} جنيه',
                      bold: true,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Divider(height: 26),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productRow({
    required String name,
    required String quantity,
    required String unitPrice,
    required String subtotal,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'الكمية: $quantity',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Text(
            'سعر الوحدة: $unitPrice جنيه',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'الإجمالي: $subtotal جنيه',
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}
