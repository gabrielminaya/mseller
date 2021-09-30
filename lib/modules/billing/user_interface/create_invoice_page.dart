import 'dart:developer';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mseller/core/di/di.dart';
import 'package:mseller/core/router/app_router.dart';
import 'package:mseller/core/utils/snackbar_message_widget.dart';
import 'package:mseller/modules/billing/business_logic/entities/invoice_item_entity.dart';
import 'package:mseller/modules/billing/business_logic/entities/invoice_options_entity.dart';
import 'package:mseller/modules/billing/business_logic/invoice_cubit/invoice_cubit.dart';
import 'package:mseller/modules/billing/business_logic/invoice_type_cubit/invoice_type_cubit.dart';
import 'package:mseller/modules/billing/user_interface/view_invoice_page.dart';
import 'package:mseller/modules/customer/business_logic/customer_cubit/customer_cubit.dart';
import 'package:mseller/modules/management/business_logic/item_cubit/item_cubit.dart';
import 'package:search_page/search_page.dart';

class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({Key? key}) : super(key: key);

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  final items = <ItemEntity>[];

  int customerId = 1;
  String customerName = "Contado";

  double netoAmount = 0;
  double itbisAmount = 0;
  double totalAmount = 0;

  void cleanValues() {
    netoAmount = 0;
    itbisAmount = 0;
    totalAmount = 0;
  }

  @override
  Widget build(BuildContext context) {
    cleanValues();
    for (var item in items) {
      if (item.hasItbis == 1) {
        netoAmount += (item.quantity * item.price) * .82;
        itbisAmount += (item.quantity * item.price) * .18;
        totalAmount += (item.quantity * item.price);
      } else {
        netoAmount += (item.quantity * item.price);
        totalAmount += (item.quantity * item.price);
      }
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di<ItemCubit>()..fetchAll(),
        ),
        BlocProvider(
          create: (context) => di<InvoiceCubit>(),
        ),
        BlocProvider(
          create: (context) => di<CustomerCubit>()..fetchAll(),
        ),
      ],
      child: Builder(builder: (context) {
        return BlocListener<InvoiceCubit, InvoiceState>(
          listener: (context, state) {
            if (state is InvoiceLoadFailure) {
              showSnackBarMessage(context: context, message: state.failure.message);
            } else if (state is InvoiceSuccess) {
              cleanValues();
              items.clear();
              customerId = 1;
              customerName = "Contado";
              setState(() {});
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Nueva venta"),
              actions: [
                BlocBuilder<CustomerCubit, CustomerState>(
                  builder: (context, state) {
                    if (state is CustomerLoaded) {
                      return IconButton(
                        icon: const Icon(Icons.person_add_alt_rounded),
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: SearchPage<Map<String, dynamic>>(
                              searchLabel: "Search customer",
                              items: state.customers,
                              filter: (item) => [item["fullname"]],
                              builder: (item) {
                                return ListTile(
                                  trailing: const Icon(Icons.touch_app_rounded),
                                  title: StatefulBuilder(builder: (context, setState) {
                                    return Text(item["fullname"]);
                                  }),
                                  onTap: () {
                                    customerId = item["id"];
                                    customerName = item["fullname"];

                                    setState(() {});

                                    pop(context);
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                IconButton(
                  onPressed: () => addNotRegisterItem(),
                  icon: const Icon(Icons.playlist_add_rounded),
                ),
                BlocBuilder<ItemCubit, ItemState>(
                  builder: (context, state) {
                    if (state is ItemLoaded) {
                      return IconButton(
                        icon: const Icon(Icons.manage_search_rounded),
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: SearchPage<Map<String, dynamic>>(
                              searchLabel: "Search item",
                              items: state.items,
                              filter: (item) => [item["description"]],
                              builder: (item) {
                                int quantity = 1;

                                return ListTile(
                                  leading: const Icon(Icons.touch_app_rounded),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Type: ${item["item_type_description"]}"),
                                      Text("Unit: ${item["unit_description"]}"),
                                      Text("Price: ${item["price"]}"),
                                    ],
                                  ),
                                  title: StatefulBuilder(builder: (context, setState) {
                                    return Row(
                                      children: [
                                        Text(item["description"]),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.arrow_back),
                                                onPressed: () {
                                                  if (quantity > 0) {
                                                    quantity--;
                                                    setState(() {});
                                                  }
                                                },
                                              ),
                                              Text(quantity.toString()),
                                              IconButton(
                                                icon: const Icon(Icons.arrow_forward),
                                                onPressed: () {
                                                  quantity++;
                                                  setState(() {});
                                                },
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    );
                                  }),
                                  onTap: () {
                                    items.removeWhere(
                                      (element) => element.id == item["id"],
                                    );
                                    items.add(
                                      ItemEntity(
                                        id: item["id"],
                                        description: item["description"],
                                        unit: item["unit_description"],
                                        quantity: quantity,
                                        hasItbis: item["has_itbis"],
                                        price: item["price"],
                                      ),
                                    );

                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              label: const Text("Complete sale"),
              onPressed: () async {
                int invoiceTypeId = 1;
                int invoiceVoucherId = 1;

                showModal(
                  context: context,
                  builder: (ctx) {
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => di<InvoiceTypeCubit>()..fetchAll(),
                        ),
                      ],
                      child: AlertDialog(
                        title: Column(
                          children: [
                            const Text("Invoice to"),
                            Text(customerName),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BlocBuilder<InvoiceTypeCubit, InvoiceTypeState>(
                              builder: (context, state) {
                                if (state is InvoiceTypeLoaded) {
                                  return DropdownButtonFormField<int>(
                                    decoration: const InputDecoration(
                                      filled: true,
                                      label: Text("Invoice Type"),
                                    ),
                                    value: invoiceTypeId,
                                    onChanged: (value) {
                                      if (value != null) {
                                        invoiceTypeId = value;
                                      }
                                    },
                                    items: [
                                      for (var item in state.invoiceTypes)
                                        DropdownMenuItem(
                                          child: Text(item["description"]),
                                          value: item["id"],
                                        )
                                    ],
                                  );
                                } else {
                                  return const LinearProgressIndicator();
                                }
                              },
                            ),
                            const Divider(),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .8,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final id =
                                      await context.read<InvoiceCubit>().createInvoice(
                                          options: InvoiceOptionEntity(
                                            invoiceTypeId: invoiceTypeId,
                                            customerId: customerId,
                                            invoiceVoucherId: invoiceVoucherId,
                                          ),
                                          items: items);

                                  if (id != null) {
                                    log(id.toString());
                                    pushReplacementPage(
                                      context,
                                      ViewInvoicePage(invoiceId: id),
                                    );
                                  } else {
                                    pop(context);
                                  }
                                },
                                child: Row(
                                  children: const [
                                    Icon(Icons.check),
                                    Expanded(
                                      child: Text(
                                        "Finish",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            body: ListView(
              padding: const EdgeInsets.all(5),
              children: [
                const Divider(),
                const Center(child: Text("Invoice to", style: TextStyle(fontSize: 12))),
                Center(child: Text(customerName, style: const TextStyle(fontSize: 15))),
                const Divider(),
                FittedBox(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      Card(
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Description"), numeric: false),
                            DataColumn(label: Text("Unit"), numeric: false),
                            DataColumn(label: Text("Quantity/Price"), numeric: true),
                            DataColumn(label: Text("Total"), numeric: true),
                            DataColumn(label: Text(""), numeric: true),
                          ],
                          rows: [
                            for (var item in items) ...[
                              DataRow(cells: [
                                DataCell(Text(item.description)),
                                DataCell(Text(item.unit)),
                                DataCell(
                                  Text(
                                      "${item.quantity}x${item.price.toStringAsFixed(2)}"),
                                ),
                                DataCell(
                                  Text((item.quantity * item.price).toStringAsFixed(2)),
                                ),
                                DataCell(IconButton(
                                  onPressed: () => setState(() {
                                    items.remove(item);
                                  }),
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                )),
                              ])
                            ],
                            const DataRow(cells: [
                              DataCell(Text("")),
                              DataCell(Text("")),
                              DataCell(Text("")),
                              DataCell(Text("")),
                              DataCell(Text("")),
                            ]),
                            DataRow(cells: [
                              const DataCell(Text("")),
                              const DataCell(Text("")),
                              const DataCell(Text("")),
                              const DataCell(Text("Neto:")),
                              DataCell(Text(netoAmount.toStringAsFixed(2))),
                            ]),
                            DataRow(cells: [
                              const DataCell(Text("")),
                              const DataCell(Text("")),
                              const DataCell(Text("")),
                              const DataCell(Text("Itbis:")),
                              DataCell(Text(itbisAmount.toStringAsFixed(2))),
                            ]),
                            DataRow(cells: [
                              const DataCell(Text("")),
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
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void addNotRegisterItem() async {
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();

    var hasItbis = false;

    await showModal(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, localSetState) {
          return AlertDialog(
            scrollable: true,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Divider(),
                Text("NOT REGISTER ITEM"),
                Divider(),
              ],
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      filled: true,
                      label: Text("description"),
                    ),
                  ),
                  const Divider(),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      filled: true,
                      label: Text("quantity"),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const Divider(),
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      filled: true,
                      label: Text("price"),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text("has itbis?"),
                    value: hasItbis,
                    onChanged: (value) => localSetState(() {
                      hasItbis = value;
                    }),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        child: const Text("Cancel"),
                        onPressed: () => pop(context),
                      ),
                      ElevatedButton(
                        child: const Text("Add"),
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;

                          items.add(
                            ItemEntity(
                              description: descriptionController.text,
                              unit: "N/D",
                              quantity: int.parse(quantityController.text),
                              hasItbis: hasItbis ? 1 : 0,
                              price: double.parse(priceController.text),
                            ),
                          );

                          setState(() {});

                          pop(context);
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
