
import 'package:el_nada_market/features/profile/domain/entities/customer_profile.dart';

class CustomerProfileModel extends CustomerProfile {
  const CustomerProfileModel({
    required super.name,
    required super.address,
    required super.phone1,
    super.phone2,
    required super.paymentMethod,
  });

  factory CustomerProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CustomerProfileModel(
      name: json['name'] as String,
      address: json['address'] as String,
      phone1: json['phone1'] as String,
      phone2: json['phone2'] as String?,
      paymentMethod: json['payment_method'] as String,
    );
  }
}
