import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mseller/core/di/di.dart';
import 'package:mseller/core/error/error_page.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/core/router/app_router.dart';
import 'package:mseller/core/utils/snackbar_message_widget.dart';
import 'package:mseller/modules/management/business_logic/category_cubit/category_cubit.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di<CategoryCubit>()..fetchAll(),
      child: const CategoryView(),
    );
  }
}

class CategoryView extends StatelessWidget {
  const CategoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CATEGORIAS"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => createOrUpdateCategory(mainContext: context, category: null),
      ),
      body: BlocConsumer<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state is CategoryLoadFailure) {
            showSnackBarMessage(context: context, message: state.failure.message);
          }
        },
        builder: (context, state) {
          if (state is CategoryLoadInProgress) {
            return const CircularProgressIndicator();
          } else if (state is CategoryLoaded) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                for (final item in state.categories) ...[
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
                          onPressed: () => createOrUpdateCategory(
                            mainContext: context,
                            category: item,
                          ),
                        ),
                        const VerticalDivider(),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).errorColor,
                          ),
                          onPressed: () {
                            context.read<CategoryCubit>().delete(id: item["id"]);
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

Future<void> createOrUpdateCategory({
  required BuildContext mainContext,
  Map<String, dynamic>? category,
}) {
  final formKey = GlobalKey<FormState>();
  final descriptionController = category == null
      ? TextEditingController()
      : TextEditingController(text: category["description"]);

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

                        if (category == null) {
                          mainContext
                              .read<CategoryCubit>()
                              .create(description: description);
                        } else {
                          mainContext
                              .read<CategoryCubit>()
                              .update(id: category["id"], description: description);
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
