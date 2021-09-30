import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mseller/core/error/failure.dart';

import '../../data_access/repositories/customer_repository.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository _customerRepository;

  CustomerCubit(this._customerRepository) : super(CustomerInitial());

  Future<void> fetchAll() async {
    emit(CustomerLoadInProgress());

    final categoriesOrFailure = await _customerRepository.getAllCustomers();

    return categoriesOrFailure.fold(
      (failure) => emit(CustomerLoadFailure(failure: failure)),
      (customers) => emit(CustomerLoaded(customers: customers)),
    );
  }

  Future<void> create({
    required String fullname,
    required String dni,
    required String address,
    required String mobile,
  }) async {
    final successOrFailure = await _customerRepository.createCustomer(
      userId: 1,
      fullname: fullname,
      dni: dni,
      address: address,
      mobile: mobile,
    );

    return successOrFailure.fold(
      (failure) async {
        emit(CustomerLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) async => await fetchAll(),
    );
  }

  Future<void> update({
    required int id,
    required String fullname,
    required String dni,
    required String address,
    required String mobile,
  }) async {
    final successOrFailure = await _customerRepository.updateCustomer(
      id: id,
      fullname: fullname,
      dni: dni,
      address: address,
      mobile: mobile,
    );

    return successOrFailure.fold(
      (failure) async {
        emit(CustomerLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) async => await fetchAll(),
    );
  }

  Future<void> delete({required int id}) async {
    final successOrFailure = await _customerRepository.deleteCustomer(id: id);

    return successOrFailure.fold(
      (failure) async {
        emit(CustomerLoadFailure(failure: failure));
        await fetchAll();
      },
      (_) async => await fetchAll(),
    );
  }
}
