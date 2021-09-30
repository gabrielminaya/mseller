import 'package:dartz/dartz.dart';
import 'package:mseller/core/error/exceptions.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database.dart';

class CategoryRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllCategories() async {
    try {
      final db = await AppDatabase.instance.database;

      final categories = await db.rawQuery(
        "SELECT * FROM item_categories WHERE status_id != 3;",
      );

      return right(categories);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> createCategory({
    required int userId,
    required String description,
  }) async {
    try {
      final db = await AppDatabase.instance.database;

      final id = await db.rawInsert("""
        INSERT INTO item_categories(description,created_by,status_id) 
        VALUES('$description', $userId,1);
      """);

      return right(id);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> updateCategory(
      {required int id, required String description}) async {
    try {
      if (id == 1) {
        throw const SystemError(message: "NO SE PUEDE MODIFICAR ESTA CATEGORIA");
      }

      final db = await AppDatabase.instance.database;

      final uid = await db.rawUpdate("""
          UPDATE item_categories SET description = ?
          WHERE id = ?
      """, [description, id]);

      return right(uid);
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> deleteCategory({required int id}) async {
    try {
      if (id == 1) {
        throw const SystemError(message: "NO SE PUEDE ELIMINAR ESTA CATEGORIA");
      }

      final db = await AppDatabase.instance.database;

      final did = await db.rawUpdate("""
          UPDATE item_categories SET status_id = 3
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
