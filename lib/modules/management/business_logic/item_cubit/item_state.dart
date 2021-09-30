part of 'item_cubit.dart';

abstract class ItemState extends Equatable {
  const ItemState();

  @override
  List<Object> get props => [];
}

class ItemInitial extends ItemState {}

class ItemLoadInProgress extends ItemState {}

class ItemLoaded extends ItemState {
  final List<Map<String, dynamic>> items;

  const ItemLoaded({
    required this.items,
  });
}

class ItemLoadFailure extends ItemState {
  final Failure failure;

  const ItemLoadFailure({
    required this.failure,
  });
}
