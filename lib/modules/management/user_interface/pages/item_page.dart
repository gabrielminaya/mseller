import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mseller/core/error/error_page.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/core/router/app_router.dart';
import 'package:mseller/core/utils/snackbar_message_widget.dart';

import '../../../../core/di/di.dart';
import '../../business_logic/category_cubit/category_cubit.dart';
import '../../business_logic/item_cubit/item_cubit.dart';
import '../../business_logic/item_type_cubit/item_type_cubit.dart';
import '../../business_logic/unit_cubit/unit_cubit.dart';

class ItemPage extends StatelessWidget {
  const ItemPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di<ItemCubit>()..fetchAll(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ITEMS"),
          actions: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context)
                        .push(PageRouteBuilder(
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SharedAxisTransition(
                              animation: animation,
                              secondaryAnimation: secondaryAnimation,
                              transitionType: SharedAxisTransitionType.horizontal,
                              child: child,
                            );
                          },
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return const ItemFormView(item: null);
                          },
                        ))
                        .then((value) => context.read<ItemCubit>().fetchAll());
                  },
                );
              },
            ),
            const IconButton(
              icon: Icon(Icons.search),
              onPressed: null,
            ),
          ],
        ),
        body: const ItemListView(),
      ),
    );
  }
}

class ItemListView extends StatelessWidget {
  const ItemListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ItemCubit, ItemState>(
      listener: (context, state) {
        if (state is ItemLoadFailure) {
          showSnackBarMessage(context: context, message: state.failure.message);
        }
      },
      builder: (context, state) {
        if (state is ItemLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ItemLoaded) {
          var itemFromDb = state.items;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    for (var item in itemFromDb) ...[
                      ListTile(
                        title: Text(" ${item["description"]}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                final date = DateTime.fromMicrosecondsSinceEpoch(
                                  item["created_date"],
                                );

                                showModal(
                                  context: context,
                                  configuration: const FadeScaleTransitionConfiguration(
                                    barrierDismissible: false,
                                  ),
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: TextEditingController(
                                              text: item["item_type_description"],
                                            ),
                                            decoration: const InputDecoration(
                                              filled: true,
                                              labelText: "TIPO",
                                            ),
                                            readOnly: true,
                                          ),
                                          const Divider(),
                                          TextField(
                                            controller: TextEditingController(
                                              text: item["price"].toString(),
                                            ),
                                            decoration: const InputDecoration(
                                              filled: true,
                                              labelText: "PRECIO",
                                            ),
                                            readOnly: true,
                                          ),
                                          const Divider(),
                                          TextField(
                                            controller: TextEditingController(
                                              text: item["item_category_description"],
                                            ),
                                            decoration: const InputDecoration(
                                              filled: true,
                                              labelText: "CATEGORIA",
                                            ),
                                            readOnly: true,
                                          ),
                                          const Divider(),
                                          TextField(
                                            controller: TextEditingController(
                                              text: item["unit_description"],
                                            ),
                                            decoration: const InputDecoration(
                                              filled: true,
                                              labelText: "UNIDAD",
                                            ),
                                            readOnly: true,
                                          ),
                                          const Divider(),
                                          TextField(
                                            controller: TextEditingController(
                                              text: item["has_stock"] == 1 ? "SI" : "NO",
                                            ),
                                            decoration: const InputDecoration(
                                              filled: true,
                                              labelText: "¿TIENE STOCK?",
                                            ),
                                            readOnly: true,
                                          ),
                                          const Divider(),
                                          TextField(
                                            controller: TextEditingController(
                                              text:
                                                  "${date.day}-${date.month}-${date.year}",
                                            ),
                                            decoration: const InputDecoration(
                                              filled: true,
                                              labelText: "FECHA DE CREACIÓN",
                                            ),
                                            readOnly: true,
                                          ),
                                          const Divider(),
                                          TextField(
                                            controller: TextEditingController(
                                              text: item["user_fullname"],
                                            ),
                                            decoration: const InputDecoration(
                                              filled: true,
                                              labelText: "CREADO POR",
                                            ),
                                            readOnly: true,
                                          ),
                                          const Divider(),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text("CERRAR"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.visibility_outlined),
                            ),
                            const VerticalDivider(),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: Theme.of(context).colorScheme.secondary,
                              onPressed: () {
                                Navigator.of(context)
                                    .push(PageRouteBuilder(
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return SharedAxisTransition(
                                          animation: animation,
                                          secondaryAnimation: secondaryAnimation,
                                          transitionType:
                                              SharedAxisTransitionType.horizontal,
                                          child: child,
                                        );
                                      },
                                      pageBuilder:
                                          (context, animation, secondaryAnimation) {
                                        return ItemFormView(item: item);
                                      },
                                    ))
                                    .then(
                                        (value) => context.read<ItemCubit>().fetchAll());
                              },
                            ),
                            const VerticalDivider(),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: Theme.of(context).errorColor,
                              onPressed: () =>
                                  context.read<ItemCubit>().delete(id: item["id"]),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                    ],
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * .035,
                width: double.infinity,
                color: Colors.grey.shade900,
                child: BlocBuilder<ItemCubit, ItemState>(
                  builder: (context, state) {
                    if (state is ItemLoaded) {
                      return Text(
                        "${state.items.length} ${state.items.length == 1 ? "ITEM" : "ITEMS"}",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      );
                    } else {
                      return const Text("NA");
                    }
                  },
                ),
              ),
            ],
          );
        } else {
          return const ErrorPage(failure: Failure(message: pageNotFoundErrorMessage));
        }
      },
    );
  }
}

class ItemFormView extends StatefulWidget {
  final Map<String, dynamic>? item;

  const ItemFormView({Key? key, this.item}) : super(key: key);

  @override
  _ItemFormViewState createState() => _ItemFormViewState();
}

class _ItemFormViewState extends State<ItemFormView> {
  final formKey = GlobalKey<FormState>();

  var _descriptionController = TextEditingController();
  var _priceController = TextEditingController();
  var _item = Item();

  @override
  void initState() {
    super.initState();

    if (widget.item == null) {
      _item = Item(
        hasStock: 0,
        hasItbis: 0,
      );
    } else {
      _descriptionController = TextEditingController(text: widget.item!["description"]);
      _priceController = TextEditingController(text: "${widget.item!["price"]}");

      _item = Item(
        description: widget.item!["description"],
        itemCategoryId: widget.item!["item_category_id"],
        itemTypeId: widget.item!["item_type_id"],
        unitId: widget.item!["unit_id"],
        hasStock: widget.item!["has_stock"],
        hasItbis: widget.item!["has_itbis"],
        price: widget.item!["price"],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? "CREAR ITEM" : "ACTUALIZAR ITEM"),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => di<ItemCubit>()..fetchAll(),
          ),
          BlocProvider(
            create: (context) => di<UnitCubit>()..fetchAll(),
          ),
          BlocProvider(
            create: (context) => di<CategoryCubit>()..fetchAll(),
          ),
          BlocProvider(
            create: (context) => di<ItemTypeCubit>()..fetchAll(),
          ),
        ],
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        filled: true,
                        labelText: "Descripción",
                      ),
                      maxLength: 30,
                      validator: (value) => value!.isEmpty ? "CAMPO NECESARIO" : null,
                    ),
                    const Divider(),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        filled: true,
                        labelText: "Precio",
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) => value!.isEmpty ? "CAMPO NECESARIO" : null,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                    ),
                    const Divider(),
                    BlocBuilder<ItemTypeCubit, ItemTypeState>(
                      builder: (context, state) {
                        if (state is ItemTypeLoadInProgress) {
                          return const LinearProgressIndicator();
                        } else if (state is ItemTypeLoaded) {
                          return DropdownButtonFormField<int>(
                            value: _item.itemTypeId,
                            decoration: const InputDecoration(
                              filled: true,
                              labelText: "Tipo de Producto",
                            ),
                            items: [
                              for (var item in state.itemTypes)
                                DropdownMenuItem(
                                  child: Text(
                                    item["description"],
                                  ),
                                  value: item["id"],
                                )
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                _item = _item.copyWith(
                                  itemTypeId: value,
                                );
                              }
                            },
                            validator: (value) =>
                                value == null ? "CAMPO NECESARIO" : null,
                          );
                        } else {
                          return const ErrorPage(
                              failure: Failure(message: pageNotFoundErrorMessage));
                        }
                      },
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: BlocBuilder<CategoryCubit, CategoryState>(
                            builder: (context, state) {
                              if (state is CategoryLoadInProgress) {
                                return const LinearProgressIndicator();
                              } else if (state is CategoryLoaded) {
                                return DropdownButtonFormField<int>(
                                  value: _item.itemCategoryId,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    labelText: "Selecciona una Categoria",
                                  ),
                                  items: [
                                    for (var item in state.categories)
                                      DropdownMenuItem(
                                        child: Text(item["description"]),
                                        value: item["id"],
                                      )
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      _item = _item.copyWith(
                                        itemCategoryId: value,
                                      );
                                    }
                                  },
                                  validator: (value) =>
                                      value == null ? "CAMPO NECESARIO" : null,
                                );
                              } else {
                                return const ErrorPage(
                                    failure: Failure(message: pageNotFoundErrorMessage));
                              }
                            },
                          ),
                        ),
                        const VerticalDivider(),
                        IconButton(
                          onPressed: () async {
                            pushReplacementNamed(context, RouteNames.categoryPage);
                          },
                          icon: const Icon(Icons.new_label_rounded),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: BlocBuilder<UnitCubit, UnitState>(
                            builder: (context, state) {
                              if (state is UnitLoadInProgress) {
                                return const LinearProgressIndicator();
                              } else if (state is UnitLoaded) {
                                return DropdownButtonFormField<int>(
                                  value: _item.unitId,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    labelText: "Selecciona una Unidad",
                                  ),
                                  items: [
                                    for (var item in state.units)
                                      DropdownMenuItem(
                                        child: Text(item["description"]),
                                        value: item["id"],
                                      )
                                  ],
                                  onChanged: (value) {
                                    _item = _item.copyWith(unitId: value);

                                    setState(() {});
                                  },
                                  validator: (value) =>
                                      value == null ? "CAMPO NECESARIO" : null,
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ),
                        const VerticalDivider(),
                        IconButton(
                          onPressed: () async {
                            pushReplacementNamed(context, RouteNames.unitPage);
                          },
                          icon: const Icon(Icons.new_label_outlined),
                        ),
                      ],
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text("¿TIENE STOCK?"),
                      value: _item.hasStock == 1,
                      onChanged: (value) {
                        _item = _item.copyWith(hasStock: value ? 1 : 0);

                        setState(() {});
                      },
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text("¿TIENE ITBIS?"),
                      value: _item.hasItbis == 1,
                      onChanged: (value) {
                        _item = _item.copyWith(hasItbis: value ? 1 : 0);

                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: BlocListener<ItemCubit, ItemState>(
                  listener: (context, state) {
                    if (state is ItemLoadFailure) {}
                  },
                  child: Builder(
                    builder: (context) {
                      return ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState == null) return;
                          if (!formKey.currentState!.validate()) return;

                          _item = _item.copyWith(
                            description: _descriptionController.text,
                            price: double.parse(_priceController.text),
                          );

                          if (widget.item == null) {
                            context.read<ItemCubit>().create(
                                  itemTypeId: _item.itemTypeId!,
                                  itemCategoryId: _item.itemCategoryId!,
                                  unitId: _item.unitId!,
                                  description: _item.description!,
                                  hasStock: _item.hasStock!,
                                  hasItbis: _item.hasItbis!,
                                  price: _item.price!,
                                );
                          } else {
                            context.read<ItemCubit>().update(
                                  id: widget.item!["id"],
                                  itemTypeId: _item.itemTypeId!,
                                  itemCategoryId: _item.itemCategoryId!,
                                  unitId: _item.unitId!,
                                  description: _item.description!,
                                  hasStock: _item.hasStock!,
                                  hasItbis: _item.hasItbis!,
                                  price: _item.price!,
                                );
                          }

                          Navigator.of(context).pop();
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.item == null ? "CREAR" : "ACTUALIZAR",
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Icon(Icons.add),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Item {
  final String? description;
  final int? itemTypeId;
  final int? itemCategoryId;
  final int? unitId;
  final int? hasStock;
  final int? hasItbis;
  final double? price;

  Item({
    this.description,
    this.itemTypeId,
    this.itemCategoryId,
    this.unitId,
    this.hasStock,
    this.hasItbis,
    this.price,
  });

  Item copyWith({
    String? description,
    int? itemTypeId,
    int? itemCategoryId,
    int? unitId,
    int? hasStock,
    int? hasItbis,
    double? price,
  }) {
    return Item(
      description: description ?? this.description,
      itemTypeId: itemTypeId ?? this.itemTypeId,
      itemCategoryId: itemCategoryId ?? this.itemCategoryId,
      unitId: unitId ?? this.unitId,
      hasStock: hasStock ?? this.hasStock,
      hasItbis: hasItbis ?? this.hasItbis,
      price: price ?? this.price,
    );
  }
}
