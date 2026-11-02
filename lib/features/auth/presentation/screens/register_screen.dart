
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:el_nada_market/core/constants/app_colors.dart';
import 'package:el_nada_market/core/widgets/custom_text_field.dart';

import '../manager/password_auth_cubit.dart';
import '../manager/password_auth_state.dart';
import '../widgets/auth_validators.dart';
import '../widgets/password_auth_header.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.onLogin,
  });

  final VoidCallback onLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _register() {
    final cubit = context.read<PasswordAuthCubit>();

    if (cubit.state is PasswordAuthLoading) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    cubit.register(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );
  }

  Widget _visibilityButton({
    required bool obscure,
    required bool isLoading,
    required VoidCallback onToggle,
  }) {
    return IconButton(
      onPressed: isLoading ? null : onToggle,
      icon: Icon(
        obscure
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        color: AppColors.hint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<
            PasswordAuthCubit,
            PasswordAuthState>(
          listenWhen: (_, current) =>
              current is PasswordAuthError,
          listener: (context, state) {
            if (state is PasswordAuthError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
          },
          builder: (context, state) {
            final isLoading = state is PasswordAuthLoading;

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        const PasswordAuthHeader(
                          isRegister: true,
                        ),

                        Transform.translate(
                          offset: const Offset(0, -26),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(
                              26,
                              38,
                              26,
                              35,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(42),
                              ),
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 420,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'إنشاء حساب جديد',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.darkGreen,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      const Text(
                                        'أدخل بياناتك لإنشاء حساب',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.hint,
                                          fontSize: 14,
                                        ),
                                      ),

                                      const SizedBox(height: 30),

                                      CustomTextField(
                                        label: 'رقم الموبايل',
                                        hintText: '01xxxxxxxxx',
                                        prefixIcon:
                                            Icons.phone_outlined,
                                        controller: _phoneController,
                                        enabled: !isLoading,
                                        keyboardType:
                                            TextInputType.phone,
                                        textDirection:
                                            TextDirection.ltr,
                                        textAlign: TextAlign.right,
                                        maxLength: 11,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        validator:
                                            AuthValidators.phone,
                                      ),

                                      const SizedBox(height: 22),

                                      CustomTextField(
                                        label: 'كلمة المرور',
                                        hintText: 'أدخل كلمة المرور',
                                        prefixIcon: Icons.lock_outline,
                                        controller:
                                            _passwordController,
                                        enabled: !isLoading,
                                        obscureText: _obscurePassword,
                                        validator: (value) =>
                                            AuthValidators.password(
                                          value,
                                          isRegister: true,
                                        ),
                                        suffixIcon: _visibilityButton(
                                          obscure: _obscurePassword,
                                          isLoading: isLoading,
                                          onToggle: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 22),

                                      CustomTextField(
                                        label: 'تأكيد كلمة المرور',
                                        hintText:
                                            'أعد إدخال كلمة المرور',
                                        prefixIcon: Icons.lock_outline,
                                        controller: _confirmController,
                                        enabled: !isLoading,
                                        obscureText:
                                            _obscureConfirmPassword,
                                        textInputAction:
                                            TextInputAction.done,
                                        validator: (value) =>
                                            AuthValidators.confirmPassword(
                                          value,
                                          _passwordController.text,
                                        ),
                                        onFieldSubmitted: (_) =>
                                            _register(),
                                        suffixIcon: _visibilityButton(
                                          obscure:
                                              _obscureConfirmPassword,
                                          isLoading: isLoading,
                                          onToggle: () {
                                            setState(() {
                                              _obscureConfirmPassword =
                                                  !_obscureConfirmPassword;
                                            });
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      SizedBox(
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed:
                                              isLoading ? null : _register,
                                          style:
                                              ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primary,
                                            foregroundColor:
                                                AppColors.background,
                                            elevation: 0,
                                            shape:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(28),
                                            ),
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  width: 23,
                                                  height: 23,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: Colors.white,
                                                  ),
                                                )
                                              : const Text(
                                                  'إنشاء حساب',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),

                                      const SizedBox(height: 26),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Flexible(
                                            child: Text(
                                              'لديك حساب بالفعل؟',
                                              style: TextStyle(
                                                color: AppColors.text,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: isLoading
                                                ? null
                                                : widget.onLogin,
                                            child: const Text(
                                              'تسجيل الدخول',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontWeight:
                                                    FontWeight.bold,
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
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
