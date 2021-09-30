import 'package:bloc/bloc.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/modules/billing/business_logic/entities/invoice_item_entity.dart';
import 'package:mseller/modules/billing/business_logic/entities/invoice_options_entity.dart';
import 'package:mseller/modules/billing/data_access/repositories/invoice_repository.dart';

part 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final InvoiceRepository _invoiceRepository;

  InvoiceCubit(this._invoiceRepository) : super(InvoiceInitial());

  Future<void> loadAllInvoices() async {
    final invoicesOrFailure = await _invoiceRepository.getAllInvoices();

    invoicesOrFailure.fold(
      (failure) => emit(InvoiceLoadFailure(failure: failure)),
      (invoices) => emit(InvoiceLoaded(invoices: invoices)),
    );
  }

  void loadInvoice({required int id}) async {
    final invoiceOrFailure = await _invoiceRepository.getInvoiceById(id: id);

    invoiceOrFailure.fold(
      (failure) => emit(InvoiceLoadFailure(failure: failure)),
      (invoice) => emit(OneInvoiceLoaded(invoice: invoice)),
    );
  }

  Future<int?> createInvoice({
    required InvoiceOptionEntity options,
    required List<ItemEntity> items,
  }) async {
    final invoiceIdOrFailure = await _invoiceRepository.createInvoice(
      options: options,
      items: items,
    );

    return invoiceIdOrFailure.fold(
      (failure) {
        emit(InvoiceLoadFailure(failure: failure));
        return null;
      },
      (invoiceId) {
        emit(InvoiceSuccess());
        return invoiceId;
      },
    );
  }

  void updateInvoice() async {}

  void deleteInvoice() async {}
}
