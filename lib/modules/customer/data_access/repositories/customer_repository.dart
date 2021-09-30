import 'package:dartz/dartz.dart';
import 'package:mseller/core/error/exceptions.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database.dart';

class CustomerRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllCustomers() async {
    try {
      final db = await AppDatabase.instance.database;

      final customers = await db.rawQuery(
        "SELECT * FROM customers WHERE status_id != 3;",
      );

      return right(customers);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> createCustomer({
    required int userId,
    required String fullname,
    required String dni,
    required String address,
    required String mobile,
  }) async {
    try {
      final db = await AppDatabase.instance.database;

      final id = await db.rawInsert("""
        INSERT INTO customers(fullname,dni,address,mobile,created_date,created_by,status_id) 
        VALUES('$fullname','$dni','$address','$mobile',${DateTime.now().microsecondsSinceEpoch},$userId,1);
      """);

      return right(id);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> updateCustomer({
    required int id,
    required String fullname,
    required String dni,
    required String address,
    required String mobile,
  }) async {
    try {
      if (id == 1) {
        throw const SystemError(message: "NO SE PUEDE MODIFICAR ESTE CLIENTE");
      }

      final db = await AppDatabase.instance.database;

      final uid = await db.rawUpdate("""
          UPDATE customers 
          SET fullname = ?,
              dni = ?,
              address = ?,
              mobile = ?
          WHERE id = ?
      """, [fullname, dni, address, mobile, id]);

      return right(uid);
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> deleteCustomer({required int id}) async {
    try {
      if (id == 1) {
        throw const SystemError(message: "NO SE PUEDE ELIMINAR ESTE CLIENTE");
      }

      final db = await AppDatabase.instance.database;

      final did = await db.rawUpdate("""
          UPDATE customers SET status_id = 3
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
