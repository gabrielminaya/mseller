import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mseller/core/di/di.dart';
import 'package:mseller/core/error/error_page.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/core/router/app_router.dart';
import 'package:mseller/core/utils/snackbar_message_widget.dart';
import 'package:mseller/modules/management/business_logic/warehouse_cubit/warehouse_cubit.dart';

class WarehousePage extends StatelessWidget {
  const WarehousePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di<WarehouseCubit>()..fetchAll(),
      child: const WarehouseView(),
    );
  }
}

class WarehouseView extends StatelessWidget {
  const WarehouseView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Almacenes"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => createOrUpdateWarehouse(mainContext: context, warehouse: null),
      ),
      body: BlocConsumer<WarehouseCubit, WarehouseState>(
        listener: (context, state) {
          if (state is WarehouseLoadFailure) {
            showSnackBarMessage(context: context, message: state.failure.message);
          }
        },
        builder: (context, state) {
          if (state is WarehouseLoadInProgress) {
            return const CircularProgressIndicator();
          } else if (state is WarehouseLoaded) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                for (final item in state.warehouses) ...[
                  ListTile(
                    title: Text(item["description"]),
                    subtitle: Text(item["address"]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () => createOrUpdateWarehouse(
                            mainContext: context,
                            warehouse: item,
                          ),
                        ),
                        const VerticalDivider(),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).errorColor,
                          ),
                          onPressed: () {
                            context.read<WarehouseCubit>().delete(id: item["id"]);
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider()
                ]
              ],
            );
          } else {
            return const ErrorPage(failure: Failure(message: pageNotFoundErrorMessage));
          }
        },
      ),
    );
  }
}

Future<void> createOrUpdateWarehouse({
  required BuildContext mainContext,
  Map<String, dynamic>? warehouse,
}) {
  final formKey = GlobalKey<FormState>();
  final descriptionController = warehouse == null
      ? TextEditingController()
      : TextEditingController(text: warehouse["description"]);
  final addressController = warehouse == null
      ? TextEditingController()
      : TextEditingController(text: warehouse["address"]);

  return showModal(
    context: mainContext,
    builder: (context) {
      return AlertDialog(
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: "Descripción",
                ),
                validator: (value) => value!.isEmpty ? "CAMPO NECESARIO" : null,
              ),
              const Divider(),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(
                  filled: true,
                  labelText: "Dirección",
                ),
                validator: (value) => value!.isEmpty ? "CAMPO NECESARIO" : null,
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.cancel),
                    label: const Text("Cancelar"),
                  ),
                  const VerticalDivider(),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (formKey.currentState != null) {
                        formKey.currentState!.validate();

                        final description = descriptionController.text;
                        final address = addressController.text;

                        if (warehouse == null) {
                          mainContext.read<WarehouseCubit>().create(
                              userId: 1, description: description, address: address);
                        } else {
                          mainContext.read<WarehouseCubit>().update(
                              id: warehouse["id"],
                              description: description,
                              address: address);
                        }

                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Aceptar"),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
