import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mseller/core/error/failure.dart';

import '../../data_access/repositories/unit_repository.dart';

part 'unit_state.dart';

class UnitCubit extends Cubit<UnitState> {
  final UnitRepository _unitRepository;

  UnitCubit(this._unitRepository) : super(UnitInitial());

  Future<void> fetchAll() async {
    emit(UnitLoadInProgress());

    final unitsOrFailure = await _unitRepository.getAllUnit();

    return unitsOrFailure.fold(
      (failure) => emit(UnitLoadFailure(failure: failure)),
      (units) => emit(UnitLoaded(units: units)),
    );
  }

  Future<void> create({required String description}) async {
    final successOrFailure = await _unitRepository.createUnit(
      userId: 1,
      description: description,
    );

    return successOrFailure.fold(
      (failure) async {
        emit(UnitLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) async => await fetchAll(),
    );
  }

  Future<void> update({required int id, required String description}) async {
    final successOrFailure = await _unitRepository.updateUnit(
      id: id,
      description: description,
    );

    return successOrFailure.fold(
      (failure) async {
        emit(UnitLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) async => await fetchAll(),
    );
  }

  Future<void> delete({required int id}) async {
    final successOrFailure = await _unitRepository.deleteUnit(id: id);

    return successOrFailure.fold(
      (failure) async {
        emit(UnitLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) async => await fetchAll(),
    );
  }
}
