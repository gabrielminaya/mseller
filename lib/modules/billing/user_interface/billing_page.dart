import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mseller/core/di/di.dart';
import 'package:mseller/core/router/app_router.dart';
import 'package:mseller/core/utils/menu_button_widget.dart';
import 'package:mseller/modules/billing/business_logic/invoice_cubit/invoice_cubit.dart';
import 'package:mseller/modules/billing/user_interface/cashier_page.dart';
import 'package:mseller/modules/billing/user_interface/create_invoice_page.dart';
import 'package:mseller/modules/billing/user_interface/view_invoice_page.dart';
import 'package:mseller/modules/customer/user_interface/customers_page.dart';
import 'package:search_page/search_page.dart';

class SearchInvoiceButton extends StatelessWidget {
  const SearchInvoiceButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di<InvoiceCubit>()..loadAllInvoices(),
      child: Builder(
          builder: (context) => Card(
                child: BlocBuilder<InvoiceCubit, InvoiceState>(
                  builder: (context, state) {
                    if (state is InvoiceLoaded) {
                      return InkWell(
                        onTap: () async {
                          await context.read<InvoiceCubit>().loadAllInvoices();

                          showSearch(
                            context: context,
                            delegate: SearchPage<Map<String, dynamic>>(
                              items: state.invoices,
                              filter: (invoice) => [
                                invoice["customer_fullname"],
                                invoice["invoice_number"],
                              ],
                              builder: (invoice) => ListTile(
                                title: Text(
                                  invoice["invoice_number"],
                                ),
                                onTap: () => pushReplacementPage(
                                  context,
                                  ViewInvoicePage(invoiceId: invoice["id"]),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search),
                            const SizedBox(height: 5),
                            Text(
                              "Facturas",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              )),
    );
  }
}

final billingButtons = [
  const MenuBotton(
    icon: Icon(Icons.point_of_sale_rounded),
    label: "Nueva Venta",
    page: CreateInvoicePage(),
  ),
  const SearchInvoiceButton(),
  const MenuBotton(
    icon: Icon(Icons.all_inbox_rounded),
    label: "Caja",
    page: CashierPage(),
  ),
  const MenuBotton(
    icon: Icon(Icons.groups),
    label: "Clientes",
    page: CustomerPage(),
  ),
  // MenuBotton(
  //   icon: const Icon(Icons.dashboard_rounded),
  //   label: "Dashboard",
  //   page: Container(),
  // ),
];

class BillingPage extends StatelessWidget {
  const BillingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.local_mall_rounded,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(.02),
            size: MediaQuery.of(context).size.width * .8,
          ),
        ),
        LiveGrid(
          padding: const EdgeInsets.all(10),
          itemCount: billingButtons.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          showItemDuration: const Duration(milliseconds: 300),
          itemBuilder: (context, index, animation) => FadeTransition(
            opacity: animation,
            child: billingButtons[index],
          ),
        ),
      ],
    );
  }
}
