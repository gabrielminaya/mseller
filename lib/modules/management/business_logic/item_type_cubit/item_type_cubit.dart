import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mseller/core/error/failure.dart';

import '../../data_access/repositories/item_type_repository.dart';

part 'item_type_state.dart';

class ItemTypeCubit extends Cubit<ItemTypeState> {
  final ItemTypeRepository _itemTypeRepository;

  ItemTypeCubit(this._itemTypeRepository) : super(ItemTypeInitial());

  Future<void> fetchAll() async {
    emit(ItemTypeLoadInProgress());

    final itemTypesOrFailure = await _itemTypeRepository.getAllItemType();

    return itemTypesOrFailure.fold(
      (failure) => emit(ItemTypeLoadFailure(failure: failure)),
      (itemTypes) => emit(ItemTypeLoaded(itemTypes: itemTypes)),
    );
  }
}
