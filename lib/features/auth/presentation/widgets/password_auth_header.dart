import 'package:flutter/material.dart';

import 'package:el_nada_market/core/constants/app_colors.dart';

class PasswordAuthHeader extends StatelessWidget {
  const PasswordAuthHeader({super.key, required this.isRegister});

  final bool isRegister;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    final foregroundColor = isRegister ? AppColors.darkGreen : Colors.white;

    return Container(
      width: double.infinity,
      height: isRegister ? 235 : 270,
      padding: EdgeInsets.fromLTRB(20, topPadding + 30, 20, 20),
      decoration: BoxDecoration(
        color: isRegister ? AppColors.background : AppColors.primary,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco_rounded,
            size: 65,
            color: isRegister ? AppColors.primary : Colors.white,
          ),
          const SizedBox(height: 15),
          Text(
            'خضروات وفواكه الندى',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: foregroundColor,
            ),
          ),
          const SizedBox(height: 13),
          Container(
            width: 65,
            height: 3,
            decoration: BoxDecoration(
              color: isRegister ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
