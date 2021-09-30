part of 'invoice_cubit.dart';

abstract class InvoiceState {
  const InvoiceState();
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoadingInProgress extends InvoiceState {}

class InvoiceSuccess extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final List<Map<String, dynamic>> invoices;

  const InvoiceLoaded({
    required this.invoices,
  });
}

class OneInvoiceLoaded extends InvoiceState {
  final Map<String, dynamic> invoice;

  const OneInvoiceLoaded({
    required this.invoice,
  });
}

class InvoiceLoadFailure extends InvoiceState {
  final Failure failure;

  const InvoiceLoadFailure({
    required this.failure,
  });
}
