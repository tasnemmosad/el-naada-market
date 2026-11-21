import 'package:el_nada_market/features/profile/domain/entities/customer_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:el_nada_market/core/theme/app_colors.dart';
import 'package:el_nada_market/features/auth/domain/entities/auth_user.dart';
import 'package:el_nada_market/features/profile/presentation/manager/profile_cubit.dart';
import 'package:el_nada_market/features/profile/presentation/manager/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  final AuthUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phone2Controller = TextEditingController();

  String selectedPayment = 'cash';

  bool _isSaving = false;

  final List<Map<String, String>> paymentMethods = [
    {'title': 'نقداً عند الاستلام', 'value': 'cash'},
    {'title': 'بطاقة بنكية', 'value': 'card'},
    {'title': 'محفظة إلكترونية', 'value': 'wallet'},
  ];

  @override
  void initState() {
    super.initState();

    _nicknameController.text = widget.user.nickname;
    _phoneController.text = widget.user.phone;
  }

  void _fillProfileFields(CustomerProfile profile) {
    _nameController.text = profile.name;
    _addressController.text = profile.address;
    _phone2Controller.text = profile.phone2 ?? '';

    if (paymentMethods.any(
      (method) => method['value'] == profile.paymentMethod,
    )) {
      selectedPayment = profile.paymentMethod;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phone2Controller.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_nameController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك أدخلي اسم العميل والعنوان')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    context.read<ProfileCubit>().updateProfile(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone2: _phone2Controller.text.trim().isEmpty
          ? null
          : _phone2Controller.text.trim(),
      paymentMethod: selectedPayment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            if (state.profile != null) {
              _fillProfileFields(state.profile!);
            }
          }

          if (state is ProfileUpdateSuccess) {
            _fillProfileFields(state.profile);

            setState(() {
              _isSaving = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حفظ البيانات بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }

          if (state is ProfileError) {
            setState(() {
              _isSaving = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileLoading;

          return Scaffold(
            backgroundColor: AppColors.background,

            appBar: AppBar(
              title: const Text('بياناتي'),
              backgroundColor: AppColors.background,
              centerTitle: true,
            ),

            body: SafeArea(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Home Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
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

                          const SizedBox(height: 18),

                          // Page Title
                          Text(
                            'بياناتي',
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                          ),

                          const SizedBox(height: 18),

                          // Nickname
                          _buildLabel('الاسم المستعار'),

                          const SizedBox(height: 8),

                          _buildTextField(
                            controller: _nicknameController,
                            hint: 'الاسم المستعار',
                            readOnly: true,
                          ),

                          const SizedBox(height: 18),

                          // Account Phone
                          _buildLabel('رقم الموبايل الأساسي'),

                          const SizedBox(height: 8),

                          _buildTextField(
                            controller: _phoneController,
                            hint: 'رقم الموبايل',
                            readOnly: true,
                          ),

                          const SizedBox(height: 18),

                          // Customer Name
                          _buildLabel('اسم العميل'),

                          const SizedBox(height: 8),

                          _buildTextField(
                            controller: _nameController,
                            hint: 'اكتب اسم العميل',
                          ),

                          const SizedBox(height: 18),

                          // Address
                          _buildLabel('عنواني'),

                          const SizedBox(height: 8),

                          _buildTextField(
                            controller: _addressController,
                            hint: 'الشارع، العمارة، الدور',
                            maxLines: 2,
                          ),

                          const SizedBox(height: 18),

                          // Secondary Phone
                          _buildLabel('رقم موبايل إضافي'),

                          const SizedBox(height: 8),

                          _buildTextField(
                            controller: _phone2Controller,
                            hint: 'رقم الموبايل الإضافي (اختياري)',
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 22),

                          // Payment Title
                          _buildLabel('كيف سأدفع؟'),

                          const SizedBox(height: 12),

                          // Payment Methods
                          ...paymentMethods.map((method) {
                            final value = method['value']!;
                            final isSelected = selectedPayment == value;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                onTap: _isSaving
                                    ? null
                                    : () {
                                        setState(() {
                                          selectedPayment = value;
                                        });
                                      },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 55,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryGreen.withValues(
                                            alpha: 0.10,
                                          )
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                          : AppColors.border,
                                      width: isSelected ? 2 : 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          method['title']!,
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: isSelected
                                            ? AppColors.primaryGreen
                                            : AppColors.textSecondary,
                                        size: 25,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 8),

                          // Save Button
                          SizedBox(
                            height: 62,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'حفظ',
                                      style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String title) {
    return Text(
      title,
      textAlign: TextAlign.right,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 17, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
    );
  }
}
