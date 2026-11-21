import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el_nada_market/core/di/set_up_locator.dart';
import 'package:el_nada_market/core/theme/app_colors.dart';
import 'package:el_nada_market/features/orders/presentation/manager/orders_cubit.dart';
import 'package:el_nada_market/features/orders/presentation/manager/orders_state.dart';
import 'package:el_nada_market/features/orders/presentation/screens/order_details_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrdersCubit>()..loadOrders(),
      child: const _OrdersView(),
    );
  }
}

class _OrdersView extends StatefulWidget {
  const _OrdersView();

  @override
  State<_OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<_OrdersView> {
  final TextEditingController _searchController = TextEditingController();

  String _searchText = '';
  String _selectedStatus = 'all';
  String _selectedDelivery = 'all';

  DateTime? _selectedDay;
  DateTimeRange? _selectedRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatMoney(dynamic value) {
    final number = double.tryParse(value.toString()) ?? 0;
    return number.toStringAsFixed(2);
  }

  String _deliveryLabel(String? type) {
    switch (type) {
      case 'delivery':
        return 'توصيل';
      case 'pickup':
        return 'استلام من المحل';
      default:
        return 'غير معروف';
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
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
        return status ?? 'غير معروف';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'preparing':
        return Colors.orange;
      default:
        return AppColors.primaryGreen;
    }
  }

  DateTime? _parseDate(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed?.toLocal();
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDateOnly(DateTime date) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${date.year}/${twoDigits(date.month)}/${twoDigits(date.day)}';
  }

  String _formatDate(dynamic value) {
    final date = _parseDate(value);

    if (date == null) {
      return 'تاريخ غير متاح';
    }

    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${_formatDateOnly(date)} - '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  bool _matchesDate(DateTime? orderDate) {
    if (_selectedDay == null && _selectedRange == null) {
      return true;
    }

    if (orderDate == null) {
      return false;
    }

    final day = _dateOnly(orderDate);

    if (_selectedDay != null) {
      return day == _dateOnly(_selectedDay!);
    }

    if (_selectedRange != null) {
      final start = _dateOnly(_selectedRange!.start);
      final end = _dateOnly(_selectedRange!.end);

      return !day.isBefore(start) && !day.isAfter(end);
    }

    return true;
  }

  List<Map<String, dynamic>> _filterOrders(List<Map<String, dynamic>> orders) {
    final search = _searchText.trim();

    return orders.where((order) {
      final id = order['id']?.toString() ?? '';
      final status = order['status']?.toString() ?? '';
      final delivery = order['delivery_type']?.toString() ?? '';

      final matchesSearch = search.isEmpty || id.contains(search);

      final matchesStatus =
          _selectedStatus == 'all' || status == _selectedStatus;

      final matchesDelivery =
          _selectedDelivery == 'all' || delivery == _selectedDelivery;

      final matchesDate = _matchesDate(_parseDate(order['created_at']));

      return matchesSearch && matchesStatus && matchesDelivery && matchesDate;
    }).toList();
  }

  Future<void> _selectSingleDay() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'اختار يوم الطلب',
      cancelText: 'إلغاء',
      confirmText: 'اختيار',
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedDay = picked;
      _selectedRange = null;
    });
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _selectedRange,
      helpText: 'اختار الفترة الزمنية',
      cancelText: 'إلغاء',
      saveText: 'تطبيق',
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedRange = picked;
      _selectedDay = null;
    });
  }

  void _clearFilters() {
    _searchController.clear();

    setState(() {
      _searchText = '';
      _selectedStatus = 'all';
      _selectedDelivery = 'all';
      _selectedDay = null;
      _selectedRange = null;
    });

    FocusScope.of(context).unfocus();
  }

  Widget _buildDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildDateFilter() {
    String dateText = 'كل التواريخ';

    if (_selectedDay != null) {
      dateText = _formatDateOnly(_selectedDay!);
    } else if (_selectedRange != null) {
      dateText =
          '${_formatDateOnly(_selectedRange!.start)}'
          ' - ${_formatDateOnly(_selectedRange!.end)}';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primaryGreen,
              ),
              SizedBox(width: 8),
              Text(
                'تاريخ الطلب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            dateText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectSingleDay,
                  icon: const Icon(Icons.today_outlined, size: 18),
                  label: const Text('يوم محدد'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range_outlined, size: 18),
                  label: const Text('فترة زمنية'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          if (_selectedDay != null || _selectedRange != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedDay = null;
                    _selectedRange = null;
                  });
                },
                icon: const Icon(Icons.close, size: 17),
                label: const Text('مسح التاريخ'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _searchController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
          onSubmitted: (_) {
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            hintText: 'ابحث برقم الطلب...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchText.isEmpty
                ? null
                : IconButton(
                    tooltip: 'مسح البحث',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchText = '';
                      });
                    },
                  ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          value: _selectedStatus,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('كل الحالات')),
            DropdownMenuItem(value: 'new', child: Text('جديد')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedStatus = value;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildDateFilter(),
        const SizedBox(height: 12),
        _buildDropdown(
          value: _selectedDelivery,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('كل طرق الاستلام')),
            DropdownMenuItem(value: 'delivery', child: Text('توصيل')),
            DropdownMenuItem(value: 'pickup', child: Text('استلام من المحل')),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedDelivery = value;
            });
          },
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.filter_alt_off_outlined),
            label: const Text('مسح الفلاتر'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('طلباتي'),
          centerTitle: true,
          backgroundColor: AppColors.background,
        ),
        body: BlocBuilder<OrdersCubit, OrdersState>(
          builder: (context, state) {
            if (state is OrdersListLoading || state is OrdersInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            if (state is OrdersError) {
              return _MessageView(
                icon: Icons.error_outline,
                message: state.message,
                buttonText: 'إعادة المحاولة',
                onPressed: () {
                  context.read<OrdersCubit>().loadOrders();
                },
              );
            }

            if (state is OrdersListLoaded) {
              final orders = _filterOrders(state.orders);

              return RefreshIndicator(
                color: AppColors.primaryGreen,
                onRefresh: () async {
                  await context.read<OrdersCubit>().loadOrders();
                },
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: _buildFilters(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'عدد الطلبات: ${orders.length}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (orders.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 55,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  state.orders.isEmpty
                                      ? 'لسه معندكش طلبات'
                                      : 'مفيش طلبات مطابقة للبحث',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final order = orders[index];

                            final orderId =
                                int.tryParse(order['id'].toString()) ?? 0;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _OrderCard(
                                orderId: orderId,
                                total: _formatMoney(order['total']),
                                date: _formatDate(order['created_at']),
                                delivery: _deliveryLabel(
                                  order['delivery_type']?.toString(),
                                ),
                                status: _statusLabel(
                                  order['status']?.toString(),
                                ),
                                statusColor: _statusColor(
                                  order['status']?.toString(),
                                ),
                                onTap: () {
                                  FocusScope.of(context).unfocus();

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          OrderDetailsScreen(orderId: orderId),
                                    ),
                                  );
                                },
                              ),
                            );
                          }, childCount: orders.length),
                        ),
                      ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final int orderId;
  final String total;
  final String date;
  final String delivery;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;

  const _OrderCard({
    required this.orderId,
    required this.total,
    required this.date,
    required this.delivery,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'طلب #$orderId',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                date,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    delivery,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Divider(height: 28),
              Row(
                children: [
                  const Text(
                    'الإجمالي',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$total جنيه',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_back_ios_new,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const _MessageView({
    required this.icon,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 65, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
