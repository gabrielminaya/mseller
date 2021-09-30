import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/modules/billing/data_access/repositories/invoice_repository.dart';

part 'invoice_detail_state.dart';

class InvoiceDetailCubit extends Cubit<InvoiceDetailState> {
  final InvoiceRepository _invoiceRepository;

  InvoiceDetailCubit(this._invoiceRepository) : super(InvoiceDetailInitial());

  void loadDetails({required int id}) async {
    final invoiceDetailsOrFailure = await _invoiceRepository.getAllInvoiceDetails(
      id: id,
    );

    invoiceDetailsOrFailure.fold(
      (failure) => emit(InvoiceDetailFailure(failure: failure)),
      (invoiceDetails) => emit(InvoiceDetailLoaded(invoiceDetails: invoiceDetails)),
    );
  }
}
