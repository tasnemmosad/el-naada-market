import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:el_nada_market/core/constants/app_colors.dart';
import 'package:el_nada_market/core/widgets/custom_text_field.dart';

class PasswordAuthForm extends StatelessWidget {
  const PasswordAuthForm({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.passwordController,
    required this.confirmController,
    required this.isRegister,
    required this.isLoading,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onSubmit,
    required this.onSwitchMode,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
  });

  final GlobalKey<FormState> formKey;

  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;

  final bool isRegister;
  final bool isLoading;
  final bool obscurePassword;
  final bool obscureConfirmPassword;

  final VoidCallback onSubmit;
  final VoidCallback onSwitchMode;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  static final RegExp _phoneRegex = RegExp(r'^01[0125][0-9]{8}$');

  // Validation
  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return 'يرجى إدخال رقم الموبايل.';
    }
    if (!_phoneRegex.hasMatch(phone)) {
      return 'يرجى إدخال رقم موبايل صحيح.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور.';
    }

    if (isRegister) {
      if (value.length < 8) {
        return 'يجب ألا تقل كلمة المرور عن 8 أحرف.';
      }

      if (utf8.encode(value).length > 72) {
        return 'كلمة المرور طويلة جدًا.';
      }
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور.';
    }

    if (value != passwordController.text) {
      return 'كلمتا المرور غير متطابقتين.';
    }

    return null;
  }
  // Password Visibility
  Widget _visibilityButton({
    required bool obscure,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: isLoading ? null : onPressed,
      tooltip: obscure ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.hint,
      ),
    );
  }
  // UI
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 38, 26, 35),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(42)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  isRegister ? 'إنشاء حساب جديد' : 'تسجيل الدخول',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                  isRegister ? 'أدخل بياناتك لإنشاء حساب' : 'أهلًا بك من جديد',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: AppColors.hint),
                ),

                const SizedBox(height: 30),
                // Phone Number
                CustomTextField(
                  label: 'رقم الموبايل',
                  hintText: '01xxxxxxxxx',
                  prefixIcon: Icons.phone_outlined,
                  controller: phoneController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  maxLength: 11,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validatePhone,
                ),

                const SizedBox(height: 22),
                // Password
                CustomTextField(
                  label: 'كلمة المرور',
                  hintText: 'أدخل كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  controller: passwordController,
                  enabled: !isLoading,
                  obscureText: obscurePassword,
                  validator: _validatePassword,
                  textInputAction: isRegister
                      ? TextInputAction.next
                      : TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!isRegister && !isLoading) {
                      onSubmit();
                    }
                  },
                  suffixIcon: _visibilityButton(
                    obscure: obscurePassword,
                    onPressed: onTogglePassword,
                  ),
                ),
                // Confirm Password
                if (isRegister) ...[
                  const SizedBox(height: 22),

                  CustomTextField(
                    label: 'تأكيد كلمة المرور',
                    hintText: 'أعد إدخال كلمة المرور',
                    prefixIcon: Icons.lock_outline,
                    controller: confirmController,
                    enabled: !isLoading,
                    obscureText: obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!isLoading) {
                        onSubmit();
                      }
                    },
                    suffixIcon: _visibilityButton(
                      obscure: obscureConfirmPassword,
                      onPressed: onToggleConfirmPassword,
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                // Login / Register Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      disabledBackgroundColor: const Color(0xFF9CCBAB),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 23,
                            height: 23,
                            child: CircularProgressIndicator(
                              color: AppColors.background,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            isRegister ? 'إنشاء حساب' : 'تسجيل الدخول',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 26),
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'أو',
                        style: TextStyle(color: AppColors.hint),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),

                const SizedBox(height: 15),
                // Switch Login / Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        isRegister ? 'لديك حساب بالفعل؟' : 'ليس لديك حساب؟',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading ? null : onSwitchMode,
                      child: Text(
                        isRegister ? 'تسجيل الدخول' : 'إنشاء حساب',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
