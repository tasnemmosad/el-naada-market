import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:el_nada_market/features/orders/data/data_sources/orders_remote_data_source.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersCubit(this.remoteDataSource) : super(OrdersInitial());

  Future<void> createOrder({
    required String deliveryType,
    required String paymentMethod,
  }) async {
    if (state is OrdersLoading) return;

    emit(OrdersLoading());

    try {
      final order = await remoteDataSource.createOrder(
        deliveryType: deliveryType,
        paymentMethod: paymentMethod,
      );

      emit(OrdersSuccess(order));
    } catch (error) {
      emit(OrdersError(_getErrorMessage(error)));
    }
  }

  Future<void> loadOrders() async {
    emit(OrdersListLoading());

    try {
      final orders = await remoteDataSource.getOrders();

      emit(OrdersListLoaded(orders));
    } catch (error) {
      emit(OrdersError(_getErrorMessage(error)));
    }
  }

  Future<void> loadOrderDetails(int orderId) async {
    emit(OrderDetailsLoading());

    try {
      final order = await remoteDataSource.getOrderDetails(orderId);

      emit(OrderDetailsLoaded(order));
    } catch (error) {
      emit(OrdersError(_getErrorMessage(error)));
    }
  }

  String _getErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      if (error.response == null) {
        return 'تعذر الاتصال بالسيرفر، تأكد من اتصال الإنترنت';
      }

      return 'حدث خطأ أثناء الاتصال بالسيرفر';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  void reset() {
    emit(OrdersInitial());
  }
}
