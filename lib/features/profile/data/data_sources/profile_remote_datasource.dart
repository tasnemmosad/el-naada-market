
import 'package:dio/dio.dart';

import 'package:el_nada_market/features/profile/data/models/customer_profile_model.dart';

class ProfileRemoteDatasource {
  final Dio dio;

  ProfileRemoteDatasource({
    required this.dio,
  });

  // GET PROFILE
  Future<CustomerProfileModel?> getProfile() async {
    final response = await dio.get<Map<String, dynamic>>(
      '/auth/profile',
    );

    final data = response.data;

    if (data == null || data['success'] != true) {
      throw const FormatException('Invalid profile response');
    }

    final profile = data['profile'];

    if (profile is! Map<String, dynamic>) {
      throw const FormatException('Profile data is missing');
    }

    final customer = profile['customer'];

    if (customer == null) {
      return null;
    }

    if (customer is! Map<String, dynamic>) {
      throw const FormatException('Invalid customer data');
    }

    return CustomerProfileModel.fromJson(customer);
  }

  // UPDATE PROFILE
  Future<void> updateProfile({
    required String name,
    required String address,
    String? phone2,
    required String paymentMethod,
  }) async {
    final response = await dio.put<Map<String, dynamic>>(
      '/auth/profile',
      data: {
        'name': name,
        'address': address,
        'phone2': phone2,
        'payment_method': paymentMethod,
      },
    );

    if (response.data?['success'] != true) {
      throw const FormatException('Profile update failed');
    }
  }
}
