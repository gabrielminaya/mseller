import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mseller/core/di/di.dart';
import 'package:mseller/core/error/error_page.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/core/router/app_router.dart';
import 'package:mseller/core/utils/snackbar_message_widget.dart';
import 'package:mseller/modules/management/business_logic/unit_cubit/unit_cubit.dart';

class UnitPage extends StatelessWidget {
  const UnitPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di<UnitCubit>()..fetchAll(),
      child: const UnitView(),
    );
  }
}

class UnitView extends StatelessWidget {
  const UnitView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unidades"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => createOrUpdateUnit(mainContext: context, unit: null),
      ),
      body: BlocConsumer<UnitCubit, UnitState>(
        listener: (context, state) {
          if (state is UnitLoadFailure) {
            showSnackBarMessage(context: context, message: state.failure.message);
          }
        },
        builder: (context, state) {
          if (state is UnitLoadInProgress) {
            return const CircularProgressIndicator();
          } else if (state is UnitLoaded) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                for (final item in state.units) ...[
                  ListTile(
                    title: Text(item["description"]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () => createOrUpdateUnit(
                            mainContext: context,
                            unit: item,
                          ),
                        ),
                        const VerticalDivider(),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).errorColor,
                          ),
                          onPressed: () {
                            context.read<UnitCubit>().delete(id: item["id"]);
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

Future<void> createOrUpdateUnit({
  required BuildContext mainContext,
  Map<String, dynamic>? unit,
}) {
  final formKey = GlobalKey<FormState>();
  final descriptionController = unit == null
      ? TextEditingController()
      : TextEditingController(text: unit["description"]);

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
                  labelText: "DESCRIPCIÓN",
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

                        if (unit == null) {
                          mainContext.read<UnitCubit>().create(description: description);
                        } else {
                          mainContext
                              .read<UnitCubit>()
                              .update(id: unit["id"], description: description);
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
