
class CustomerProfile {
  final String name;
  final String address;
  final String phone1;
  final String? phone2;
  final String paymentMethod;

  const CustomerProfile({
    required this.name,
    required this.address,
    required this.phone1,
    this.phone2,
    required this.paymentMethod,
  });
}
