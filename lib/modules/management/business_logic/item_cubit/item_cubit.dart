import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/modules/management/data_access/repositories/item_repository.dart';

part 'item_state.dart';

class ItemCubit extends Cubit<ItemState> {
  final ItemRepository _itemRepository;

  ItemCubit(this._itemRepository) : super(ItemInitial());

  Future<void> fetchAll() async {
    emit(ItemLoadInProgress());

    final unitsOrFailure = await _itemRepository.getAllItem();

    return unitsOrFailure.fold(
      (failure) => emit(ItemLoadFailure(failure: failure)),
      (items) => emit(ItemLoaded(items: items)),
    );
  }

  Future<void> create({
    required int itemTypeId,
    required int itemCategoryId,
    required int unitId,
    required String description,
    required int hasStock,
    required int hasItbis,
    required double price,
  }) async {
    final successOrFailure = await _itemRepository.createItem(
      userId: 1,
      itemTypeId: itemTypeId,
      itemCategoryId: itemCategoryId,
      unitId: unitId,
      description: description,
      hasStock: hasStock,
      hasItbis: hasItbis,
      price: price,
    );

    return successOrFailure.fold(
      (failure) async {
        emit(ItemLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) async => await fetchAll(),
    );
  }

  Future<void> update({
    required int id,
    required int itemTypeId,
    required int itemCategoryId,
    required int unitId,
    required String description,
    required int hasStock,
    required int hasItbis,
    required double price,
  }) async {
    final successOrFailure = await _itemRepository.updateItem(
      id: id,
      itemTypeId: itemTypeId,
      itemCategoryId: itemCategoryId,
      unitId: unitId,
      description: description,
      hasStock: hasStock,
      hasItbis: hasItbis,
      price: price,
    );

    return successOrFailure.fold(
      (failure) async {
        emit(ItemLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) async => await fetchAll(),
    );
  }

  Future<void> delete({required int id}) async {
    final successOrFailure = await _itemRepository.deleteItem(id: id);

    return successOrFailure.fold(
      (failure) async {
        emit(ItemLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) async => await fetchAll(),
    );
  }
}
