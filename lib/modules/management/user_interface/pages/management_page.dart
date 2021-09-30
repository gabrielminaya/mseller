import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:mseller/core/utils/menu_button_widget.dart';
import 'package:mseller/modules/management/user_interface/pages/category_page.dart';
import 'package:mseller/modules/management/user_interface/pages/inventory_page.dart';
import 'package:mseller/modules/management/user_interface/pages/item_page.dart';
import 'package:mseller/modules/management/user_interface/pages/unit_page.dart';
import 'package:mseller/modules/management/user_interface/pages/warehouse_page.dart';

final maintenanceButtons = [
  // MenuBotton(
  //   icon: const Icon(Icons.settings),
  //   label: "Settings",
  //   page: Container(),
  // ),
  const MenuBotton(
    icon: Icon(Icons.category),
    label: "Categories",
    page: CategoryPage(),
  ),
  const MenuBotton(
    icon: Icon(Icons.inventory_2),
    label: "Items",
    page: ItemPage(),
  ),
  const MenuBotton(
    icon: Icon(Icons.home),
    label: "Warehouses",
    page: WarehousePage(),
  ),
  const MenuBotton(
    icon: Icon(Icons.assignment_ind_rounded),
    label: "Units",
    page: UnitPage(),
  ),
  const MenuBotton(
    icon: Icon(Icons.inventory_rounded),
    label: "Inventory",
    page: InventoryPage(),
  ),
  // MenuBotton(
  //   icon: const Icon(Icons.view_in_ar),
  //   label: "Users",
  //   page: Container(),
  // ),
  // MenuBotton(
  //   icon: const Icon(Icons.summarize),
  //   label: "Reports",
  //   page: Container(),
  // ),
  // MenuBotton(
  //   icon: const Icon(Icons.backup_rounded),
  //   label: "Backup",
  //   page: Container(),
  // ),
];

class ManagementPage extends StatelessWidget {
  const ManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.inventory_rounded,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(.02),
            size: MediaQuery.of(context).size.width * .8,
          ),
        ),
        LiveGrid(
          padding: const EdgeInsets.all(10),
          itemCount: maintenanceButtons.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          showItemDuration: const Duration(milliseconds: 300),
          itemBuilder: (context, index, animation) => FadeTransition(
            opacity: animation,
            child: maintenanceButtons[index],
          ),
        ),
      ],
    );
  }
}
