import 'package:dartz/dartz.dart';
import 'package:mseller/core/error/exceptions.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database.dart';

class WarehousesRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllWarehouses() async {
    try {
      final db = await AppDatabase.instance.database;

      final categories = await db.rawQuery(
        "SELECT * FROM warehouses WHERE status_id != 3;",
      );

      return right(categories);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> createWarehouses({
    required int userId,
    required String description,
    required String address,
  }) async {
    try {
      final db = await AppDatabase.instance.database;

      final id = await db.rawInsert("""
        INSERT INTO warehouses(description,address,created_date,created_by,status_id) 
        VALUES('$description','$address',${DateTime.now().microsecondsSinceEpoch},$userId,1);
      """);

      return right(id);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> updateWarehouses({
    required int id,
    required String description,
    required String address,
  }) async {
    try {
      if (id == 1) {
        throw const SystemError(message: "NO SE PUEDE MODIFICAR ESTE ALMACEN");
      }

      final db = await AppDatabase.instance.database;

      final uid = await db.rawUpdate("""
          UPDATE warehouses SET description = ?, address = ?
          WHERE id = ?
      """, [description, address, id]);

      return right(uid);
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> deleteWarehouses({required int id}) async {
    try {
      if (id == 1) {
        throw const SystemError(message: "NO SE PUEDE ELIMINAR ESTE ALMACEN");
      }

      final db = await AppDatabase.instance.database;

      final uid = await db.rawUpdate("""
          UPDATE warehouses SET status_id = 3
          WHERE id = ?
      """, [id]);

      return right(uid);
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  addItemToWarehouse() {}

  updateItemToWarehouse() {}

  removeItemToWarehouse() {}
}
