part of 'category_cubit.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoadInProgress extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<Map<String, dynamic>> categories;

  // ignore: prefer_const_constructors_in_immutables
  CategoryLoaded({required this.categories});
}

class CategoryLoadFailure extends CategoryState {
  final Failure failure;

  // ignore: prefer_const_constructors_in_immutables
  CategoryLoadFailure({required this.failure});
}
