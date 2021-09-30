class InvoiceOptionEntity {
  final int invoiceTypeId;
  final int customerId;
  final int invoiceVoucherId;

  const InvoiceOptionEntity({
    required this.invoiceTypeId,
    required this.customerId,
    required this.invoiceVoucherId,
  });
}
