
import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductsRemoteDataSource {
  final Dio dio;

  ProductsRemoteDataSource(this.dio);

  Future<List<ProductModel>> getProducts() async {
    final response = await dio.get('/products');

    final data = response.data as Map<String, dynamic>;
    final productsJson = data['products'] as List;

    return productsJson
        .map(
          (item) => ProductModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
