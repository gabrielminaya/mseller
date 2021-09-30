part of 'invoice_type_cubit.dart';

abstract class InvoiceTypeState {}

class InvoiceTypeInitial extends InvoiceTypeState {}

class InvoiceTypeLoadInProgress extends InvoiceTypeState {}

class InvoiceTypeLoaded extends InvoiceTypeState {
  final List<Map<String, dynamic>> invoiceTypes;

  InvoiceTypeLoaded({
    required this.invoiceTypes,
  });
}

class InvoiceTypeLoadFailure extends InvoiceTypeState {
  final Failure failure;

  InvoiceTypeLoadFailure({
    required this.failure,
  });
}
