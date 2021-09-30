part of 'unit_cubit.dart';

abstract class UnitState extends Equatable {
  const UnitState();

  @override
  List<Object> get props => [];
}

class UnitInitial extends UnitState {}

class UnitLoadInProgress extends UnitState {}

class UnitLoaded extends UnitState {
  final List<Map<String, dynamic>> units;

  const UnitLoaded({
    required this.units,
  });
}

class UnitLoadFailure extends UnitState {
  final Failure failure;

  const UnitLoadFailure({
    required this.failure,
  });
}
