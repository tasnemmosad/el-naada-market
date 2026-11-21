import 'package:dio/dio.dart';

class OrdersRemoteDataSource {
  final Dio dio;

  OrdersRemoteDataSource(this.dio);

  Future<Map<String, dynamic>> createOrder({
    required String deliveryType,
    required String paymentMethod,
  }) async {
    final response = await dio.post(
      '/orders',
      data: {'delivery_type': deliveryType, 'payment_method': paymentMethod},
    );

    if (response.data is! Map) {
      throw const FormatException('Invalid order response');
    }

    final data = Map<String, dynamic>.from(response.data);

    if (data['success'] != true || data['order'] is! Map) {
      throw Exception(data['message'] ?? 'فشل إنشاء الطلب');
    }

    return Map<String, dynamic>.from(data['order']);
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await dio.get('/orders');

    if (response.data is! Map) {
      throw const FormatException('Invalid orders response');
    }

    final data = Map<String, dynamic>.from(response.data);

    if (data['success'] != true || data['orders'] is! List) {
      throw Exception(data['message'] ?? 'فشل تحميل الطلبات');
    }

    return (data['orders'] as List)
        .map((order) => Map<String, dynamic>.from(order as Map))
        .toList();
  }

  Future<Map<String, dynamic>> getOrderDetails(int orderId) async {
    final response = await dio.get('/orders/$orderId');

    if (response.data is! Map) {
      throw const FormatException('Invalid order details response');
    }

    final data = Map<String, dynamic>.from(response.data);

    if (data['success'] != true || data['order'] is! Map) {
      throw Exception(data['message'] ?? 'فشل تحميل تفاصيل الطلب');
    }

    return Map<String, dynamic>.from(data['order']);
  }
}
