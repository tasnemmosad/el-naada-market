sealed class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersSuccess extends OrdersState {
  final Map<String, dynamic> order;

  OrdersSuccess(this.order);
}

class OrdersError extends OrdersState {
  final String message;

  OrdersError(this.message);
}

class OrdersListLoading extends OrdersState {}

class OrdersListLoaded extends OrdersState {
  final List<Map<String, dynamic>> orders;

  OrdersListLoaded(this.orders);
}

class OrderDetailsLoading extends OrdersState {}

class OrderDetailsLoaded extends OrdersState {
  final Map<String, dynamic> order;

  OrderDetailsLoaded(this.order);
}
