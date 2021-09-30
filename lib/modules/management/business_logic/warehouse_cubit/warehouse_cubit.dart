import 'package:bloc/bloc.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/modules/management/data_access/repositories/warehouse_repository.dart';

part 'warehouse_state.dart';

class WarehouseCubit extends Cubit<WarehouseState> {
  final WarehousesRepository _warehouseRepository;

  WarehouseCubit(this._warehouseRepository) : super(WarehouseInitial());

  Future<void> fetchAll() async {
    final warehouseOrFailure = await _warehouseRepository.getAllWarehouses();

    warehouseOrFailure.fold(
      (failure) => emit(WarehouseLoadFailure(failure: failure)),
      (warehouses) => emit(WarehouseLoaded(warehouses: warehouses)),
    );
  }

  Future<void> create({
    required int userId,
    required String description,
    required String address,
  }) async {
    final successOrFailure = await _warehouseRepository.createWarehouses(
      userId: userId,
      description: description,
      address: address,
    );

    successOrFailure.fold(
      (failure) async {
        emit(WarehouseLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) => fetchAll(),
    );
  }

  Future<void> update({
    required int id,
    required String description,
    required String address,
  }) async {
    final successOrFailure = await _warehouseRepository.updateWarehouses(
      id: id,
      description: description,
      address: address,
    );

    successOrFailure.fold(
      (failure) async {
        emit(WarehouseLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) => fetchAll(),
    );
  }

  Future<void> delete({required int id}) async {
    final successOrFailure = await _warehouseRepository.deleteWarehouses(id: id);

    successOrFailure.fold(
      (failure) async {
        emit(WarehouseLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) => fetchAll(),
    );
  }
}
