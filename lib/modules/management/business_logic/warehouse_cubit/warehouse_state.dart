part of 'warehouse_cubit.dart';

abstract class WarehouseState {}

class WarehouseInitial extends WarehouseState {}

class WarehouseLoadInProgress extends WarehouseState {}

class WarehouseLoaded extends WarehouseState {
  final List<Map<String, dynamic>> warehouses;

  WarehouseLoaded({
    required this.warehouses,
  });
}

class WarehouseLoadFailure extends WarehouseState {
  final Failure failure;

  WarehouseLoadFailure({
    required this.failure,
  });
}
