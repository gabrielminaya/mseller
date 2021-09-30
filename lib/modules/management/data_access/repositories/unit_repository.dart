import 'package:dartz/dartz.dart';
import 'package:mseller/core/error/exceptions.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database.dart';

class UnitRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllUnit() async {
    try {
      final db = await AppDatabase.instance.database;

      final categories = await db.rawQuery(
        "SELECT * FROM units WHERE status_id != 3;",
      );

      return right(categories);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> createUnit({
    required int userId,
    required String description,
  }) async {
    try {
      final db = await AppDatabase.instance.database;

      final id = await db.rawInsert("""
        INSERT INTO units(description,created_by,status_id) 
        VALUES('$description', $userId,1);
      """);

      return right(id);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> updateUnit(
      {required int id, required String description}) async {
    try {
      if (id == 1) {
        throw const SystemError(message: "NO SE PUEDE MODIFICAR ESTA UNIDAD");
      }

      final db = await AppDatabase.instance.database;

      final uid = await db.rawUpdate("""
          UPDATE units SET description = ?
          WHERE id = ?
      """, [description, id]);

      return right(uid);
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> deleteUnit({required int id}) async {
    try {
      if (id == 1) {
        throw const SystemError(message: "NO SE PUEDE ELIMINAR ESTA UNIDAD");
      }

      final db = await AppDatabase.instance.database;

      final uid = await db.rawUpdate("""
          UPDATE units SET status_id = 3
          WHERE id = ?
      """, [id]);

      return right(uid);
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
