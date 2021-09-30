import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mseller/core/di/di.dart';
import 'package:mseller/core/error/error_page.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/core/router/app_router.dart';
import 'package:mseller/modules/customer/business_logic/customer_cubit/customer_cubit.dart';
import 'package:mseller/modules/customer/user_interface/receivable_page.dart';
import 'package:search_page/search_page.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di<CustomerCubit>()..fetchAll(),
      child: const CustomerView(),
    );
  }
}

class CustomerView extends StatelessWidget {
  const CustomerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<CustomerCubit, CustomerState>(
          builder: (context, state) {
            if (state is CustomerLoaded) {
              return Text(
                "Customers (${state.customers.length})",
                style: const TextStyle(fontSize: 14.5),
              );
            } else {
              return const LinearProgressIndicator();
            }
          },
        ),
        actions: [
          BlocBuilder<CustomerCubit, CustomerState>(
            builder: (context, state) {
              if (state is CustomerLoaded) {
                final List<Map<String, dynamic>> customers = List.from(state.customers);
                customers.removeWhere((element) => element["id"] == 1);

                return IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => showSearch(
                    context: context,
                    delegate: SearchPage<Map<String, dynamic>>(
                      items: customers,
                      filter: (customer) => [customer["fullname"]],
                      builder: (customer) {
                        return ListTile(
                          onTap: () => pushPage(
                            context,
                            ReceivablePage(customerId: customer["id"]),
                          ),
                          title: Text(customer["fullname"]),
                          subtitle: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("DNI: ${customer["dni"]}"),
                              Text("Contacto: ${customer["mobile"]}"),
                              const Text("Monto Pendiente 0.00"),
                            ],
                          ),
                          leading: const Icon(Icons.folder_shared_rounded),
                        );
                      },
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              Navigator.of(context)
                  .push(PageRouteBuilder(
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child,
                      );
                    },
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return const CustomerFormView();
                    },
                  ))
                  .then((value) => context.read<CustomerCubit>().fetchAll());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CustomerCubit, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CustomerLoaded) {
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      for (final item in state.customers)
                        if (item["id"] != 1) ...[
                          ListTile(
                            onTap: () => pushPage(
                              context,
                              ReceivablePage(customerId: item["id"]),
                            ),
                            title: Text(item["fullname"]),
                            subtitle: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("DNI: ${item["dni"]}"),
                                Text("Contacto: ${item["mobile"]}"),
                                const Text("Monto Pendiente 0.00"),
                              ],
                            ),
                            leading: const Icon(Icons.folder_shared_rounded),
                          ),
                          const Divider(),
                        ]
                    ],
                  );
                } else {
                  return const ErrorPage(
                    failure: Failure(message: pageNotFoundErrorMessage),
                  );
                }
              },
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * .035,
            width: double.infinity,
            color: Colors.grey.shade900,
            child: Text(
              r"BALANCE PENDIENTE TOTAL: RD$ 0.00",
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.height * .016,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerFormView extends StatefulWidget {
  final Map<String, dynamic>? customer;

  const CustomerFormView({
    Key? key,
    this.customer,
  }) : super(key: key);

  @override
  _CustomerFormViewState createState() => _CustomerFormViewState();
}

class _CustomerFormViewState extends State<CustomerFormView> {
  final formKey = GlobalKey<FormState>();

  var fullnameController = TextEditingController();
  var dniController = TextEditingController();
  var mobileController = TextEditingController();
  var addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.customer == null) {
      fullnameController = TextEditingController();
      dniController = TextEditingController();
      mobileController = TextEditingController();
      addressController = TextEditingController();
    } else {
      fullnameController = TextEditingController(text: widget.customer!["fullname"]);
      dniController = TextEditingController(text: widget.customer!["dni"]);
      mobileController = TextEditingController(text: widget.customer!["mobile"]);
      addressController = TextEditingController(text: widget.customer!["address"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create customer"),
      ),
      body: BlocProvider(
        create: (context) => di<CustomerCubit>(),
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: fullnameController,
                        decoration: const InputDecoration(
                          filled: true,
                          labelText: "NOMBRE COMPLETO",
                        ),
                        maxLength: 20,
                        validator: (value) => value!.isEmpty ? "CAMPO NECESARIO" : null,
                      ),
                      const Divider(),
                      TextFormField(
                        controller: dniController,
                        decoration: const InputDecoration(
                          filled: true,
                          labelText: "DNI",
                        ),
                        maxLength: 15,
                        validator: (value) => value!.isEmpty ? "CAMPO NECESARIO" : null,
                      ),
                      const Divider(),
                      TextFormField(
                        controller: mobileController,
                        decoration: const InputDecoration(
                          filled: true,
                          labelText: "CONTACTO",
                        ),
                        maxLength: 20,
                        validator: (value) => value!.isEmpty ? "CAMPO NECESARIO" : null,
                      ),
                      const Divider(),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          filled: true,
                          labelText: "DIRECCIÓN",
                        ),
                        maxLength: 80,
                        maxLines: 3,
                        validator: (value) => value!.isEmpty ? "CAMPO NECESARIO" : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Builder(builder: (context) {
                    return BlocListener<CustomerCubit, CustomerState>(
                      listener: (context, state) {
                        if (state is CustomerLoadFailure) {}
                      },
                      child: ElevatedButton(
                        child: Row(
                          children: const [
                            Expanded(
                              child: Text("CREAR", textAlign: TextAlign.center),
                            ),
                            Icon(Icons.check),
                          ],
                        ),
                        onPressed: () async {
                          if (formKey.currentState == null) return;
                          if (!formKey.currentState!.validate()) return;

                          final fullname = fullnameController.text;
                          final dni = dniController.text;
                          final mobile = mobileController.text;
                          final address = addressController.text;

                          if (widget.customer == null) {
                            await context.read<CustomerCubit>().create(
                                fullname: fullname,
                                dni: dni,
                                address: address,
                                mobile: mobile);
                          } else {
                            await context.read<CustomerCubit>().update(
                                id: widget.customer!["id"],
                                fullname: fullname,
                                dni: dni,
                                address: address,
                                mobile: mobile);
                          }

                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
