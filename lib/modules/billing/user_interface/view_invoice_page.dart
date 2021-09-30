import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mseller/core/di/di.dart';
import 'package:mseller/modules/billing/business_logic/invoice_cubit/invoice_cubit.dart';
import 'package:mseller/modules/billing/business_logic/invoice_detail_cubit/invoice_detail_cubit.dart';

class ViewInvoicePage extends StatelessWidget {
  final int invoiceId;

  const ViewInvoicePage({Key? key, required this.invoiceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di<InvoiceCubit>()..loadInvoice(id: invoiceId),
        ),
        BlocProvider(
          create: (context) => di<InvoiceDetailCubit>()..loadDetails(id: invoiceId),
        ),
      ],
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: BlocBuilder<InvoiceCubit, InvoiceState>(
              builder: (context, state) {
                if (state is OneInvoiceLoaded) {
                  return Text(state.invoice["invoice_number"]);
                } else {
                  return const LinearProgressIndicator();
                }
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.print_rounded),
                onPressed: () {},
              )
            ],
          ),
          body: BlocBuilder<InvoiceCubit, InvoiceState>(
            builder: (context, state) {
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  BlocBuilder<InvoiceCubit, InvoiceState>(
                    builder: (context, state) {
                      if (state is OneInvoiceLoaded) {
                        final date = DateTime.fromMicrosecondsSinceEpoch(
                          state.invoice["emission_date"],
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Numero de factura: ${state.invoice["invoice_number"]}",
                            ),
                            const Divider(),
                            Text(
                              "Tipo de factura: ${state.invoice["INVOICE_TYPE_DESCRIPTION"]}",
                            ),
                            const Divider(),
                            Text(
                              "Tipo de comprobante: ${state.invoice["invoice_voucher"]}",
                            ),
                            const Divider(),
                            Text(
                              "Cliente: ${state.invoice["CUSTOMER_FULLNAME"]}",
                            ),
                            const Divider(),
                            Text(
                              "Fecha de emisión: ${date.day}-${date.month}-${date.year}",
                            ),
                            const Divider(),
                            Text(
                              "Creado por: ${state.invoice["USER_FULLNAME"]}",
                            ),
                            const Divider(),
                          ],
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  const Divider(),
                  BlocBuilder<InvoiceDetailCubit, InvoiceDetailState>(
                    builder: (context, state) {
                      if (state is InvoiceDetailLoaded) {
                        double netoAmount = 0;
                        double itbisAmount = 0;
                        double totalAmount = 0;

                        for (var item in state.invoiceDetails) {
                          if (item["has_itbis"] == 1) {
                            netoAmount += (item["quantity"] * item["price"]) * .82;
                            itbisAmount += (item["quantity"] * item["price"]) * .18;
                            totalAmount += (item["quantity"] * item["price"]);
                          } else {
                            netoAmount += (item["quantity"] * item["price"]);
                            totalAmount += (item["quantity"] * item["price"]);
                          }
                        }

                        return FittedBox(
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: [
                              Card(
                                child: DataTable(
                                  columns: const [
                                    DataColumn(
                                      label: Text("Description"),
                                      numeric: false,
                                    ),
                                    DataColumn(label: Text("Unit"), numeric: false),
                                    DataColumn(
                                      label: Text("Quantity/Price"),
                                      numeric: true,
                                    ),
                                    DataColumn(label: Text("Total"), numeric: true),
                                  ],
                                  rows: [
                                    for (var item in state.invoiceDetails) ...[
                                      DataRow(cells: [
                                        DataCell(Text(item["item_description"])),
                                        DataCell(Text(item["unit_description"])),
                                        DataCell(
                                          Text(
                                              "${item["quantity"]}x${item["price"].toStringAsFixed(2)}"),
                                        ),
                                        DataCell(
                                          Text((item["quantity"] * item["price"])
                                              .toStringAsFixed(2)),
                                        ),
                                      ])
                                    ],
                                    const DataRow(cells: [
                                      DataCell(Text("")),
                                      DataCell(Text("")),
                                      DataCell(Text("")),
                                      DataCell(Text("")),
                                    ]),
                                    DataRow(cells: [
                                      const DataCell(Text("")),
                                      const DataCell(Text("")),
                                      const DataCell(Text("Neto:")),
                                      DataCell(Text(netoAmount.toStringAsFixed(2))),
                                    ]),
                                    DataRow(cells: [
                                      const DataCell(Text("")),
                                      const DataCell(Text("")),
                                      const DataCell(Text("Itbis:")),
                                      DataCell(Text(itbisAmount.toStringAsFixed(2))),
                                    ]),
                                    DataRow(cells: [
                                      const DataCell(Text("")),
                                      const DataCell(Text("")),
                                      const DataCell(Text("Total:")),
                                      DataCell(Text(totalAmount.toStringAsFixed(2))),
                                    ]),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const LinearProgressIndicator();
                      }
                    },
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}
