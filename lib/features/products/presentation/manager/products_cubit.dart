
import 'package:el_nada_market/features/products/data/data_sources/products_remote_data_source.dart';
import 'package:el_nada_market/features/products/data/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductsRemoteDataSource dataSource;

  ProductsCubit(this.dataSource) : super(ProductsInitial());

  Future<void> getProducts() async {
    emit(ProductsLoading());

    try {
      final products = await dataSource.getProducts();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}
