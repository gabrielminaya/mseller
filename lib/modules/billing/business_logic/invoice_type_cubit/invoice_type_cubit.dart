import 'package:bloc/bloc.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/modules/billing/data_access/repositories/invoice_repository.dart';

part 'invoice_type_state.dart';

class InvoiceTypeCubit extends Cubit<InvoiceTypeState> {
  final InvoiceRepository _invoiceRepository;

  InvoiceTypeCubit(this._invoiceRepository) : super(InvoiceTypeInitial());

  fetchAll() async {
    final invoiceTypesOrFailure = await _invoiceRepository.getInvoiceTypes();

    invoiceTypesOrFailure.fold(
      (failure) => emit(InvoiceTypeLoadFailure(failure: failure)),
      (invoiceTypes) => emit(
        InvoiceTypeLoaded(invoiceTypes: invoiceTypes),
      ),
    );
  }
}
