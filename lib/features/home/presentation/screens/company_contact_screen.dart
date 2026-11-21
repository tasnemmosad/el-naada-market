import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:el_nada_market/core/di/set_up_locator.dart';
import 'package:el_nada_market/core/theme/app_colors.dart';

class CompanyContactScreen extends StatefulWidget {
  const CompanyContactScreen({super.key});

  @override
  State<CompanyContactScreen> createState() => _CompanyContactScreenState();
}

class _CompanyContactScreenState extends State<CompanyContactScreen> {
  late Future<Map<String, dynamic>> _companyFuture;

  @override
  void initState() {
    super.initState();
    _companyFuture = _loadCompany();
  }

  Future<Map<String, dynamic>> _loadCompany() async {
    final response = await sl<Dio>().get('/company');
    final data = response.data;

    if (data is! Map || data['success'] != true || data['company'] is! Map) {
      throw Exception('تعذر تحميل بيانات المحل');
    }

    return Map<String, dynamic>.from(data['company'] as Map);
  }

  void _retry() {
    setState(() {
      _companyFuture = _loadCompany();
    });
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: AppColors.primaryGreen),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          title: const Text('بيانات المحل'),
          centerTitle: true,
          backgroundColor: AppColors.background,
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _companyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    const Text('تعذر تحميل بيانات المحل'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _retry,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            final company = snapshot.data!;

            final name = company['name']?.toString() ?? '';
            final address = company['address']?.toString() ?? '';
            final phone = company['phone']?.toString() ?? '';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      const Icon(
                        Icons.storefront_outlined,
                        size: 75,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'معلومات المحل',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _infoCard(
                        icon: Icons.store_outlined,
                        title: 'اسم المحل',
                        value: name,
                      ),
                      const SizedBox(height: 14),
                      _infoCard(
                        icon: Icons.location_on_outlined,
                        title: 'عنوان المحل',
                        value: address,
                      ),
                      const SizedBox(height: 14),
                      _infoCard(
                        icon: Icons.phone_outlined,
                        title: 'رقم التليفون',
                        value: phone,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
