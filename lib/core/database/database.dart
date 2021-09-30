import 'dart:developer';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final instance = AppDatabase._init();
  static Database? _database;
  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDb('mseller.db');

    return _database!;
  }

  Future<Database> _initDb(String fileName) async {
    final appPath = await getApplicationDocumentsDirectory();
    final databasePath = path.join(appPath.path, fileName);
    return await openDatabase(databasePath, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    log("initializing database.");

    await db.transaction((txn) async {
      // TABLAS COMUNES

      await txn.execute("""
        CREATE TABLE app_settings(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          business_logo BLOB,
          business_invoice_code TEXT NOT NULL,
          business_name TEXT NOT NULL,
          currentInvoiceNumber INTEGER NOT NULL
        );
      """);

      await txn.execute("""
        CREATE TABLE status(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL
        );
      """);

      await txn.execute("""
        CREATE TABLE user_types(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL
        );
      """);

      await txn.execute("""
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_type_id INTEGER NOT NULL REFERENCES user_types(id),
          fullname TEXT NOT NULL,
          username TEXT NOT NULL,
          password TEXT NOT NULL,
          cashier_code integer,
          created_date integer NOT NULL,
          status_id INTEGER NOT NULL REFERENCES status(id)
        );
      """);

      await txn.execute("""
        CREATE TABLE customers(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          fullname TEXT NOT NULL,
          dni TEXT NOT NULL UNIQUE,
          address TEXT NOT NULL,
          mobile TEXT NOT NULL,
          created_date TEXT NOT NULL,
          created_by INTEGER NOT NULL REFERENCES users(id),
          status_id INTEGER NOT NULL REFERENCES status(id)
        );
      """);

      // TABLAS DEL MODOULO [inventory]

      await txn.execute("""
        CREATE TABLE units(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL,
          created_by INTEGER NOT NULL REFERENCES users(id),
          status_id INTEGER NOT NULL REFERENCES status(id)
        );
      """);

      await txn.execute("""
        CREATE TABLE item_types(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL,
          created_by INTEGER NOT NULL REFERENCES users(id),
          status_id INTEGER NOT NULL REFERENCES status(id)
        );
      """);

      await txn.execute("""
        CREATE TABLE item_categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL,
          created_by INTEGER NOT NULL REFERENCES users(id),
          status_id INTEGER NOT NULL REFERENCES status(id)
        );
      """);

      await txn.execute("""
        CREATE TABLE items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          item_type_id integer NOT NULL REFERENCES item_types(id),
          item_category_id integer REFERENCES item_categories(id),
          unit_id integer NOT NULL REFERENCES units(id) DEFAULT 1,
          description TEXT NOT NULL,
          has_stock integer NOT NULL DEFAULT 0,
          has_itbis integer NOT NULL DEFAULT 0,
          price REAL NOT NULL,
          created_date integer NOT NULL,
          created_by INTEGER NOT NULL REFERENCES users(id),
          status_id INTEGER NOT NULL REFERENCES status(id)
        );
      """);

      await txn.execute("""
        CREATE TABLE warehouses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL,
          address TEXT NOT NULL,
          created_date integer NOT NULL,
          created_by INTEGER NOT NULL REFERENCES users(id),
          status_id INTEGER NOT NULL REFERENCES status(id)
        );
      """);

      await txn.execute("""
        CREATE TABLE item_in_warehouses(
          item_id integer NOT NULL REFERENCES items(id),
          warehouse_id integer NOT NULL REFERENCES units(id),
          stock integer NOT NULL DEFAULT 0,
          created_date integer NOT NULL,
          created_by INTEGER NOT NULL REFERENCES users(id),
          status_id INTEGER NOT NULL REFERENCES status(id),
          PRIMARY KEY(item_id,warehouse_id)
        );
      """);

      // TABLAS DEL MODOULO [billing]

      await txn.execute("""
        CREATE TABLE cashiers(
          effective_date TEXT PRIMARY KEY,
          opened_by INTEGER NOT NULL REFERENCES users(id),
          opened_hour INTEGER NOT NULL REFERENCES users(id),
          closed_by INTEGER REFERENCES users(id),
          closed_hour INTEGER,
          open_total_amount REAL NOT NULL,
          close_total_amount REAL
        );
      """);

      await txn.execute("""
        CREATE TABLE currencies(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL,
          status_id INTEGER NOT NULL REFERENCES status(id)
        );
      """);

      await txn.execute("""
        CREATE TABLE invoice_types(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          description TEXT NOT NULL
        );
      """);

      await txn.execute("""
        CREATE TABLE invoices(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          invoice_type_id INTEGER NOT NULL REFERENCES invoice_types(id),
          customer_id INTEGER NOT NULL REFERENCES customers(id),
          invoice_number TEXT NOT NULL,
          invoice_voucher TEXT,
          total_amount REAL NOT NULL,
          created_by INTEGER NOT NULL REFERENCES users(id),
          emission_date INTEGER NOT NULL, 
          status_id INTEGER NOT NULL REFERENCES status(id)
        );
      """);

      await txn.execute("""
        CREATE TABLE invoice_details(
          invoice_id INTEGER NOT NULL REFERENCES invoices(id),
          item_id integer REFERENCES items(id),
          item_description TEXT NOT NULL,
          unit_description TEXT NOT NULL,
          has_itbis INTEGER NOT NULL,
          quantity INTEGER NOT NULL,
          price REAL NOT NULL
        );
      """);

      await txn.execute("""
         CREATE TABLE invoice_amounts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          invoice_id INTEGER NOT NULL REFERENCES invoices(id),
          received_by INTEGER NOT NULL REFERENCES users(id),
          amount REAL NOT NULL,
          date INTEGER NOT NULL,
          status_id INTEGER NOT NULL REFERENCES status(id)
        );
      """);

      await txn.rawQuery("""
        INSERT INTO app_settings(id,business_logo,business_invoice_code,business_name,currentInvoiceNumber) 
        VALUES(1,NULL,'MS','MSELLER', 1);
      """);

      await txn.rawQuery("""
        INSERT INTO STATUS(id,description) VALUES(1,'Activo');
      """);

      await txn.rawQuery("""
        INSERT INTO STATUS(id,description) VALUES(2,'Inactivo');
      """);

      await txn.rawQuery("""
        INSERT INTO STATUS(id,description) VALUES(3,'Borrado');
      """);

      await txn.rawQuery("""
        INSERT INTO STATUS(id,description) VALUES(4,'Anulado');
      """);

      await txn.rawQuery("""
        INSERT INTO item_types(id,description,created_by,status_id) VALUES(1,'Producto',1,1);
      """);

      await txn.rawQuery("""
        INSERT INTO item_types(id,description,created_by,status_id) VALUES(2,'Servicio',1,1);
      """);

      await txn.rawQuery("""
        INSERT INTO user_types(id,description) VALUES(1,'Admin');
      """);

      await txn.rawQuery("""
        INSERT INTO user_types(id,description) VALUES(2,'Seller');
      """);

      await txn.rawQuery("""
        INSERT INTO invoice_types(id,description) VALUES(1,'Efectivo');
      """);

      await txn.rawQuery("""
        INSERT INTO invoice_types(id,description) VALUES(2,'Crédito');
      """);

      await txn.rawQuery("""
        INSERT INTO invoice_types(id,description) VALUES(3,'Tarjeta');
      """);

      await txn.rawQuery("""
        INSERT INTO invoice_types(id,description) VALUES(4,'Cheque');
      """);

      await txn.rawQuery("""
        INSERT INTO invoice_types(id,description) VALUES(5,'Tranferencia');
      """);

      await txn.rawQuery("""
        INSERT INTO currencies(id,description,status_id) VALUES(1,'DOP',1);
      """);

      await txn.rawQuery("""
        INSERT INTO USERS(id,user_type_id,fullname,username,password,cashier_code,created_date,status_id) 
        VALUES(1,1,'MSELLER ADMINISTRADOR', 'admin', 'admin', 0000 ,${DateTime.now().microsecondsSinceEpoch},1);
      """);

      await txn.rawQuery("""
        INSERT INTO units(id,description,created_by,status_id) 
        VALUES(1,'UNIDAD',1,1);
      """);

      await txn.rawQuery("""
        INSERT INTO item_categories(id,description,created_by,status_id) 
        VALUES(1,'DEFAULT',1,1);
      """);

      await txn.rawQuery("""
        INSERT INTO warehouses(id,description,address,created_date,created_by,status_id) 
        VALUES(1,'ALMACEN PRINCIPAL','NO APLICA',${DateTime.now().microsecondsSinceEpoch},1,1);
      """);

      await txn.rawQuery("""
        INSERT INTO customers(id,fullname,dni,address,mobile,created_date,created_by,status_id) 
        VALUES(1,'Contado','No aplica','No aplica','No aplica',${DateTime.now().microsecondsSinceEpoch},1,1);
      """);
    });
    log("database was created successfuly.");
  }

  Future<void> close() async {
    final database = await instance.database;
    return await database.close();
  }
}
