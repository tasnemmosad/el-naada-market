import 'package:el_nada_market/features/home/presentation/screens/company_contact_screen.dart';
import 'package:el_nada_market/features/orders/presentation/manager/orders_cubit.dart';
import 'package:el_nada_market/features/orders/presentation/screens/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:el_nada_market/core/di/set_up_locator.dart';
import 'package:el_nada_market/core/theme/app_colors.dart';
import 'package:el_nada_market/features/auth/domain/entities/auth_user.dart';
import 'package:el_nada_market/features/cart/manager/cart_cubit.dart';
import 'package:el_nada_market/features/cart/manager/cart_state.dart';
import 'package:el_nada_market/features/cart/presentation/cart_screen.dart';

class HomeScreen extends StatelessWidget {
  final Future<void> Function() onLogout;

  final VoidCallback? onFruits;
  final VoidCallback? onVegetables;
  final VoidCallback? onCart;
  final VoidCallback? onProfile;
  final VoidCallback? onSearch;
  final VoidCallback? onContact;

  final String storeName;
  final AuthUser user;

  const HomeScreen({
    super.key,
    required this.user,
    required this.onLogout,
    this.onFruits,
    this.onVegetables,
    this.onCart,
    this.onProfile,
    this.onSearch,
    this.onContact,
    this.storeName = 'خضروات وفواكه الندى',
  });

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _openCart(BuildContext context) {
    if (onCart != null) {
      onCart!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<OrdersCubit>(),
          child: const CartScreen(),
        ),
      ),
    );
  }

  void _openOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrdersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopBar(context),

                      const SizedBox(height: 28),

                      _buildWelcomeSection(context),

                      const SizedBox(height: 24),

                      // قسم الفواكه
                      _buildCategoryCard(
                        context: context,
                        title: 'فواكه',
                        imagePath: 'assets/images/fruits.jfif',
                        onTap:
                            onFruits ??
                            () => _showMessage(
                              context,
                              'صفحة الفواكه سيتم ربطها قريبًا',
                            ),
                      ),
                      const SizedBox(height: 16),

                      // قسم الخضروات
                      _buildCategoryCard(
                        context: context,
                        title: 'خضروات',
                        imagePath: 'assets/images/vegetables.jfif',
                        onTap:
                            onVegetables ??
                            () => _showMessage(
                              context,
                              'صفحة الخضروات سيتم ربطها قريبًا',
                            ),
                      ),

                      const SizedBox(height: 20),

                      BlocBuilder<CartCubit, CartState>(
                        buildWhen: (previous, current) {
                          if (previous is CartUpdated &&
                              current is CartUpdated) {
                            return previous.quantities.length !=
                                current.quantities.length;
                          }
                          return true;
                        },
                        builder: (context, state) {
                          final itemCount = state is CartUpdated
                              ? state.quantities.values
                                    .where((quantity) => quantity > 0)
                                    .length
                              : 0;

                          return _buildOutlinedButton(
                            title: 'سلتي ($itemCount)',
                            icon: Icons.shopping_cart_outlined,
                            onPressed: () => _openCart(context),
                          );
                        },
                      ),

                      const SizedBox(height: 14),

                      _buildOutlinedButton(
                        title: 'طلباتي',
                        icon: Icons.receipt_long_outlined,
                        onPressed: () => _openOrders(context),
                      ),

                      const SizedBox(height: 14),

                      // الزر الثالث: بياناتي
                      _buildOutlinedButton(
                        title: 'بياناتي',
                        icon: Icons.person_outline,
                        onPressed:
                            onProfile ??
                            () => _showMessage(
                              context,
                              'صفحة بياناتي سيتم ربطها قريبًا',
                            ),
                      ),

                      const SizedBox(height: 28),

                      _buildContactButton(context),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            IconButton(
              onPressed:
                  onSearch ?? () => _showMessage(context, 'البحث قريبًا'),
              icon: const Icon(Icons.search),
              color: AppColors.textPrimary,
              tooltip: 'بحث',
            ),

            Expanded(
              child: Center(
                child: Text(
                  'الصفحة الرئيسية',
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),

            PopupMenuButton<String>(
              tooltip: 'القائمة',
              icon: const Icon(Icons.menu, color: AppColors.primaryGreen),
              onSelected: (value) async {
                if (value == 'logout') {
                  await onLogout();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 10),
                      Text('تسجيل الخروج'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            storeName,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'ماذا تريد أن تشتري؟',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 178,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                cacheWidth: 1100,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primaryGreen,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  );
                },
              ),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      Colors.black.withValues(alpha: 0.60),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    title,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primaryGreen,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          side: const BorderSide(color: AppColors.primaryGreen, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, size: 30, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return TextButton(
      onPressed:
          onContact ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompanyContactScreen()),
            );
          },
      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_outlined, size: 17),
          SizedBox(width: 8),
          Text(
            'اتصل بالمحل',
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
