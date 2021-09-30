import 'package:get_it/get_it.dart';
import 'package:mseller/modules/auth/business_logic/auth_cubit.dart';
import 'package:mseller/modules/billing/business_logic/invoice_cubit/invoice_cubit.dart';
import 'package:mseller/modules/billing/business_logic/invoice_detail_cubit/invoice_detail_cubit.dart';
import 'package:mseller/modules/billing/business_logic/invoice_type_cubit/invoice_type_cubit.dart';
import 'package:mseller/modules/billing/data_access/repositories/invoice_repository.dart';
import 'package:mseller/modules/customer/business_logic/customer_cubit/customer_cubit.dart';
import 'package:mseller/modules/customer/data_access/repositories/customer_repository.dart';
import 'package:mseller/modules/management/business_logic/category_cubit/category_cubit.dart';
import 'package:mseller/modules/management/business_logic/item_cubit/item_cubit.dart';
import 'package:mseller/modules/management/business_logic/item_type_cubit/item_type_cubit.dart';
import 'package:mseller/modules/management/business_logic/unit_cubit/unit_cubit.dart';
import 'package:mseller/modules/management/business_logic/warehouse_cubit/warehouse_cubit.dart';
import 'package:mseller/modules/management/data_access/repositories/category_repository.dart';
import 'package:mseller/modules/management/data_access/repositories/item_repository.dart';
import 'package:mseller/modules/management/data_access/repositories/item_type_repository.dart';
import 'package:mseller/modules/management/data_access/repositories/unit_repository.dart';
import 'package:mseller/modules/management/data_access/repositories/warehouse_repository.dart';

final di = GetIt.I;

Future<void> initDependecies() async {
  final _categoryRepository = CategoryRepository();
  final _itemRepository = ItemRepository();
  final _unitRepository = UnitRepository();
  final _itemTypeRepository = ItemTypeRepository();
  final _invoiceRepository = InvoiceRepository();
  final _customerRepository = CustomerRepository();
  final _warehouseRepository = WarehousesRepository();

  di.registerFactory(() => AuthCubit());
  di.registerFactory(() => CategoryCubit(_categoryRepository));
  di.registerFactory(() => CustomerCubit(_customerRepository));
  di.registerFactory(() => ItemCubit(_itemRepository));
  di.registerFactory(() => ItemTypeCubit(_itemTypeRepository));
  di.registerFactory(() => UnitCubit(_unitRepository));
  di.registerFactory(() => InvoiceCubit(_invoiceRepository));
  di.registerFactory(() => InvoiceDetailCubit(_invoiceRepository));
  di.registerFactory(() => InvoiceTypeCubit(_invoiceRepository));
  di.registerFactory(() => WarehouseCubit(_warehouseRepository));
}
