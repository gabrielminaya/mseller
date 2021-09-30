import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mseller/core/error/failure.dart';

import '../../data_access/repositories/category_repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryCubit(this._categoryRepository) : super(CategoryInitial());

  Future<void> fetchAll() async {
    emit(CategoryLoadInProgress());

    final categoriesOrFailure = await _categoryRepository.getAllCategories();

    return categoriesOrFailure.fold(
      (failure) => emit(CategoryLoadFailure(failure: failure)),
      (categories) => emit(CategoryLoaded(categories: categories)),
    );
  }

  Future<void> create({required String description}) async {
    final successOrFailure = await _categoryRepository.createCategory(
      userId: 1,
      description: description,
    );

    return successOrFailure.fold(
      (failure) async {
        emit(CategoryLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) async => await fetchAll(),
    );
  }

  Future<void> update({required int id, required String description}) async {
    final successOrFailure = await _categoryRepository.updateCategory(
      id: id,
      description: description,
    );

    return successOrFailure.fold(
      (failure) async {
        emit(CategoryLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) async => await fetchAll(),
    );
  }

  Future<void> delete({required int id}) async {
    final successOrFailure = await _categoryRepository.deleteCategory(id: id);

    return successOrFailure.fold(
      (failure) async {
        emit(CategoryLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) async => await fetchAll(),
    );
  }
}
