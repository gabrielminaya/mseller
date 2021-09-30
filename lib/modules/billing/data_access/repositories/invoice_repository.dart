import 'package:dartz/dartz.dart';
import 'package:mseller/core/database/database.dart';
import 'package:mseller/core/error/exceptions.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:mseller/modules/billing/business_logic/entities/invoice_item_entity.dart';
import 'package:mseller/modules/billing/business_logic/entities/invoice_options_entity.dart';
import 'package:sqflite/sqflite.dart';

class InvoiceRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getInvoiceTypes() async {
    try {
      final db = await AppDatabase.instance.database;

      final invoiceTypes = await db.rawQuery(
        "SELECT * FROM invoice_types;",
      );

      return right(invoiceTypes);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getAllInvoices() async {
    try {
      final db = await AppDatabase.instance.database;

      final invoices = await db.rawQuery("""
        SELECT INVOICES.ID,
          INVOICES.INVOICE_TYPE_ID,
          INVOICE_TYPES.DESCRIPTION AS INVOICE_TYPE_DESCRIPTION,
          INVOICES.CUSTOMER_ID,
          INVOICES.INVOICE_NUMBER,
          INVOICES.INVOICE_VOUCHER,
          INVOICES.TOTAL_AMOUNT,
          INVOICES.CREATED_BY,
          INVOICES.EMISSION_DATE,
          CUSTOMERS.FULLNAME AS CUSTOMER_FULLNAME,
          USERS.FULLNAME AS USER_FULLNAME
        FROM INVOICES
        INNER JOIN INVOICE_TYPES ON INVOICE_TYPES.ID = INVOICES.INVOICE_TYPE_ID
        INNER JOIN CUSTOMERS ON CUSTOMERS.ID = INVOICES.CUSTOMER_ID
        INNER JOIN USERS ON USERS.ID = INVOICES.CREATED_BY
        WHERE INVOICES.STATUS_ID != 3;
      """);

      return right(invoices);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getInvoiceById({required int id}) async {
    try {
      final db = await AppDatabase.instance.database;

      final invoice = await db.rawQuery("""
        SELECT INVOICES.ID,
          INVOICES.INVOICE_TYPE_ID,
          INVOICE_TYPES.DESCRIPTION AS INVOICE_TYPE_DESCRIPTION,
          INVOICES.CUSTOMER_ID,
          INVOICES.INVOICE_NUMBER,
          INVOICES.INVOICE_VOUCHER,
          INVOICES.TOTAL_AMOUNT,
          INVOICES.CREATED_BY,
          INVOICES.EMISSION_DATE,
          CUSTOMERS.FULLNAME AS CUSTOMER_FULLNAME,
          USERS.FULLNAME AS USER_FULLNAME
        FROM INVOICES
        INNER JOIN INVOICE_TYPES ON INVOICE_TYPES.ID = INVOICES.INVOICE_TYPE_ID
        INNER JOIN CUSTOMERS ON CUSTOMERS.ID = INVOICES.CUSTOMER_ID
        INNER JOIN USERS ON USERS.ID = INVOICES.CREATED_BY
        WHERE INVOICES.STATUS_ID != 3 AND INVOICES.ID = $id;
      """);

      return right(invoice[0]);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getAllInvoiceDetails({
    required int id,
  }) async {
    try {
      final db = await AppDatabase.instance.database;

      final invoices = await db.rawQuery("""
        SELECT 
          invoice_id,
          item_id,
          item_description,
          unit_description,
          has_itbis,
          quantity,
          price
        FROM invoice_details
        WHERE invoice_details.invoice_id = $id
      """);

      return right(invoices);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> createInvoice({
    required InvoiceOptionEntity options,
    required List<ItemEntity> items,
  }) async {
    try {
      if (items.isEmpty) {
        return throw const SystemError(message: "You must add at least 1 item");
      }

      int invoiceId = 0;
      double totalAmount = 0.0;

      final db = await AppDatabase.instance.database;

      for (final item in items) {
        totalAmount += item.quantity * item.price;
      }

      await db.transaction((txn) async {
        final List<Map<String, dynamic>> appSetting = await txn.rawQuery("""
          SELECT * FROM app_settings LIMIT 1;
        """);

        int currentInvoiceNumber = int.parse(
          appSetting[0]["currentInvoiceNumber"].toString(),
        );

        String currentInvoiceCode = appSetting[0]["business_invoice_code"];

        currentInvoiceNumber += 1;

        invoiceId = await txn.rawInsert("""
          INSERT INTO invoices(
            invoice_type_id,
            customer_id,
            invoice_number,
            invoice_voucher,
            total_amount,
            created_by,
            emission_date,
            status_id
            ) VALUES (${options.invoiceTypeId},${options.customerId},'$currentInvoiceCode${currentInvoiceNumber.toString().padLeft(10, '0')}','-',$totalAmount, ${1},${DateTime.now().microsecondsSinceEpoch},1);
        """);

        await txn.rawUpdate("""
          UPDATE app_settings SET currentInvoiceNumber = ? WHERE id = ?;
        """, [currentInvoiceNumber, 1]);

        for (final item in items) {
          await txn.rawInsert("""
            INSERT INTO invoice_details(
              invoice_id,
              item_id,
              item_description,
              unit_description,
              has_itbis,
              quantity,
              price
            ) VALUES ($invoiceId,${item.id},'${item.description}','${item.unit}',${item.hasItbis},${item.quantity},${item.price});
          """);
        }
      });

      return right(invoiceId);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    }
  }

  // Future<Either<Failure, int>> updateInvoice() {}

  Future<Either<Failure, int>> deleteInvoice() async {
    try {
      final db = await AppDatabase.instance.database;

      final did = await db.rawUpdate("""
          UPDATE invoices SET status_id = 3
          WHERE id = ?
      """, [id]);

      return right(did);
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
