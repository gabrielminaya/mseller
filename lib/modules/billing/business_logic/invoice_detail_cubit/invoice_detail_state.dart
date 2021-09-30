part of 'invoice_detail_cubit.dart';

abstract class InvoiceDetailState extends Equatable {
  const InvoiceDetailState();

  @override
  List<Object> get props => [];
}

class InvoiceDetailInitial extends InvoiceDetailState {}

class InvoiceDetaiLoadInProgress extends InvoiceDetailState {}

class InvoiceDetailLoaded extends InvoiceDetailState {
  final List<Map<String, dynamic>> invoiceDetails;

  const InvoiceDetailLoaded({
    required this.invoiceDetails,
  });
}

class InvoiceDetailFailure extends InvoiceDetailState {
  final Failure failure;

  const InvoiceDetailFailure({
    required this.failure,
  });
}
