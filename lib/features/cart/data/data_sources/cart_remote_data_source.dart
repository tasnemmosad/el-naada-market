
import 'package:dio/dio.dart';


class CartRemoteDataSource {
  final Dio dio;

  CartRemoteDataSource(this.dio);

  Future<List<Map<String, dynamic>>> getBasket() async {
    final response = await dio.get('/basket');

    final data = response.data;

    if (data is! Map || data['items'] is! List) {
      throw const FormatException('Invalid basket response');
    }

    return (data['items'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }


  Future<void> updateQuantity({
    required int productId,
    required double quantity,
  }) async {
    await dio.post(
      '/basket',
      data: {
        'product_id': productId,
        'quantity': quantity,
      },
    );
  }


  Future<void> removeProduct(int productId) async {
    await dio.delete('/basket/$productId');
  }


  Future<void> clearBasket() async {
    await dio.delete('/basket');
  }
  Future<Map<String, dynamic>> createOrder({
  required String deliveryType,
  required String paymentMethod,
}) async {
  final response = await dio.post(
    '/orders',
    data: {
      'delivery_type': deliveryType,
      'payment_method': paymentMethod,
    },
  );

  if (response.data is! Map) {
    throw const FormatException('Invalid order response');
  }

  return Map<String, dynamic>.from(response.data);
}
}
