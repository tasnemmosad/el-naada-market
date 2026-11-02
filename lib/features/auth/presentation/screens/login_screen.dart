import 'package:el_nada_market/features/auth/presentation/widgets/auth_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:el_nada_market/core/constants/app_colors.dart';
import 'package:el_nada_market/core/widgets/custom_text_field.dart';

import '../manager/password_auth_cubit.dart';
import '../manager/password_auth_state.dart';

import '../widgets/password_auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onCreateAccount});

  final VoidCallback onCreateAccount;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final cubit = context.read<PasswordAuthCubit>();

    if (cubit.state is PasswordAuthLoading) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    cubit.login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<PasswordAuthCubit, PasswordAuthState>(
          listenWhen: (_, current) => current is PasswordAuthError,
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const PasswordAuthHeader(isRegister: false),

                        Transform.translate(
                          offset: const Offset(0, -26),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(26, 38, 26, 35),
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
                                        'تسجيل الدخول',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.darkGreen,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      const Text(
                                        'أهلًا بك من جديد',
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
                                        prefixIcon: Icons.phone_outlined,
                                        controller: _phoneController,
                                        enabled: !isLoading,
                                        keyboardType: TextInputType.phone,
                                        textDirection: TextDirection.ltr,
                                        textAlign: TextAlign.right,
                                        maxLength: 11,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        validator: AuthValidators.phone,
                                      ),

                                      const SizedBox(height: 22),

                                      CustomTextField(
                                        label: 'كلمة المرور',
                                        hintText: 'أدخل كلمة المرور',
                                        prefixIcon: Icons.lock_outline,
                                        controller: _passwordController,
                                        enabled: !isLoading,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        validator: AuthValidators.password,
                                        onFieldSubmitted: (_) => _login(),
                                        suffixIcon: IconButton(
                                          onPressed: isLoading
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _obscurePassword =
                                                        !_obscurePassword;
                                                  });
                                                },
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: AppColors.hint,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 32),

                                      SizedBox(
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: isLoading ? null : _login,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor:
                                                AppColors.background,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
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
                                                  'تسجيل الدخول',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
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
                                              'ليس لديك حساب؟',
                                              style: TextStyle(
                                                color: AppColors.text,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: isLoading
                                                ? null
                                                : widget.onCreateAccount,
                                            child: const Text(
                                              'إنشاء حساب',
                                              style: TextStyle(
                                                color: AppColors.primary,
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
