

import 'package:el_nada_market/features/cart/manager/cart_cubit.dart';
import 'package:el_nada_market/features/cart/manager/cart_state.dart';
import 'package:el_nada_market/features/cart/presentation/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:el_nada_market/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  final Future<void> Function() onLogout;

  final VoidCallback? onFruits;
  final VoidCallback? onVegetables;
  final VoidCallback? onCart;
  final VoidCallback? onProfile;
  final VoidCallback? onSearch;
  final VoidCallback? onContact;

 
  final String storeName;

  const HomeScreen({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 520,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                        children: [
                          _buildTopBar(context),

                          const SizedBox(height: 28),

                          _buildWelcomeSection(context),

                          const SizedBox(height: 24),

                          _buildCategoryCard(
                            context: context,
                            title: 'فواكه',
                            color: AppColors.fruitRed,
                            icon: Icons.apple,
                            onTap: onFruits ??
                                () => _showMessage(
                                      context,
                                      'صفحة الفواكه سيتم ربطها قريبًا',
                                    ),
                          ),

                          const SizedBox(height: 16),

                          _buildCategoryCard(
                            context: context,
                            title: 'خضروات',
                            color: AppColors.primaryGreen,
                            icon: Icons.eco_outlined,
                            onTap: onVegetables ??
                                () => _showMessage(
                                      context,
                                      'صفحة الخضروات سيتم ربطها قريبًا',
                                    ),
                          ),

                          const SizedBox(height: 18),

                        
BlocBuilder<CartCubit, CartState>(
  builder: (context, state) {
    final count = state is CartUpdated
        ? state.totalQuantity
        : 0;

    return _buildOutlinedButton(
      context: context,
      title: 'سلتي ($count)',
      icon: Icons.shopping_basket_outlined,
      onPressed: onCart ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CartScreen(),
              ),
            );
          },
    );
  },
),

                          const SizedBox(height: 14),

                          _buildOutlinedButton(
                            context: context,
                            title: 'بياناتي',
                            icon: Icons.person_outline,
                            onPressed: onProfile ??
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
              );
            },
          ),
        ),
      ),
    );
  }

  // Top Navigation Bar



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
            onPressed: onSearch ??
                () => _showMessage(context, 'البحث قريبًا'),
            icon: const Icon(Icons.search),
            color: AppColors.textPrimary,
            tooltip: 'بحث',
          ),

          Expanded(
            child: Center(
              child: Text(
                'الصفحة الرئيسية',
                textDirection: TextDirection.rtl,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
              ),
            ),
          ),

          PopupMenuButton<String>(
            tooltip: 'القائمة',
            icon: const Icon(
              Icons.menu,
              color: AppColors.primaryGreen,
            ),
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


  // Welcome Section

 

Widget _buildWelcomeSection(BuildContext context) {
  return Column(
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: Text(
          'خضروات وفواكه الندى',
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    ],
  );
}


  // Fruit and Vegetable Cards

  // Widget _buildCategoryCard({
  //   required BuildContext context,
  //   required String title,
  //   required Color color,
  //   required IconData icon,
  //   required VoidCallback onTap,
  // }) {
  //   return Material(
  //     color: color,
  //     borderRadius: BorderRadius.circular(18),
  //     clipBehavior: Clip.antiAlias,
  //     child: InkWell(
  //       onTap: onTap,
  //       child: SizedBox(
  //         height: 178,
  //         width: double.infinity,
  //         child: Stack(
  //           alignment: Alignment.center,
  //           children: [
  //             Positioned(
  //               left: 18,
  //               top: 18,
  //               child: Icon(
  //                 icon,
  //                 color: Colors.white.withValues(alpha: 0.13),
  //                 size: 70,
  //               ),
  //             ),

  //             Text(
  //               title,
  //               style: Theme.of(context)
  //                   .textTheme
  //                   .headlineLarge
  //                   ?.copyWith(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 27,
  //                   ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

Widget _buildCategoryCard({
  required BuildContext context,
  required String title,
  required Color color,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Material(
    color: color,
    borderRadius: BorderRadius.circular(14),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 178,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              title,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 27,
                  ),
            ),
          ),
        ),
      ),
    ),
  );
}

  // Basket and Profile Buttons



Widget _buildOutlinedButton({
  required BuildContext context,
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
        side: const BorderSide(
          color: AppColors.primaryGreen,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            icon,
            size: 32,
            color: AppColors.primaryGreen,
          ),
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

  // Contact Section

  Widget _buildContactButton(BuildContext context) {
    return TextButton(
      onPressed: onContact ??
          () => _showMessage(
                context,
                'سيتم إضافة رقم المحل لاحقًا',
              ),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_outlined,
            size: 17,
          ),
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
