part of 'item_type_cubit.dart';

abstract class ItemTypeState extends Equatable {
  const ItemTypeState();

  @override
  List<Object> get props => [];
}

class ItemTypeInitial extends ItemTypeState {}

class ItemTypeLoadInProgress extends ItemTypeState {}

class ItemTypeLoaded extends ItemTypeState {
  final List<Map<String, dynamic>> itemTypes;

  const ItemTypeLoaded({
    required this.itemTypes,
  });
}

class ItemTypeLoadFailure extends ItemTypeState {
  final Failure failure;

  const ItemTypeLoadFailure({
    required this.failure,
  });
}
