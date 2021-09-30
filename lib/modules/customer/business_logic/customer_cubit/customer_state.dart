part of 'customer_cubit.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoadInProgress extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<Map<String, dynamic>> customers;

  const CustomerLoaded({
    required this.customers,
  });
}

class CustomerLoadFailure extends CustomerState {
  final Failure failure;

  const CustomerLoadFailure({
    required this.failure,
  });
}
