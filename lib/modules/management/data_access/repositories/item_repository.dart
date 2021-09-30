import 'package:dartz/dartz.dart';
import 'package:mseller/core/error/exceptions.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database.dart';

class ItemRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllItem() async {
    try {
      final db = await AppDatabase.instance.database;

      final categories = await db.rawQuery("""
          SELECT
            items.id,
            items.item_type_id,
            item_types.description as item_type_description,
            items.item_category_id,
            item_categories.description as item_category_description,
            items.unit_id,
            units.description as unit_description,
            items.description,
            items.has_stock,
            items.has_itbis,
            items.price,
            items.created_date,
            items.created_by,
            users.fullname as user_fullname,
            items.status_id
          FROM items 
          INNER JOIN item_types ON item_types.id = items.item_type_id
          INNER JOIN item_categories ON item_categories.id = items.item_category_id
          INNER JOIN units ON units.id = items.unit_id
          INNER JOIN users ON users.id = items.created_by
          WHERE items.status_id != 3 
          ORDER BY items.description;
      """);

      return right(categories);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> createItem({
    required int userId,
    required int itemTypeId,
    required int itemCategoryId,
    required int unitId,
    required double price,
    required String description,
    required int hasStock,
    required int hasItbis,
  }) async {
    try {
      final db = await AppDatabase.instance.database;

      final id = await db.rawInsert("""
        INSERT INTO items(
          item_type_id,
          item_category_id,
          unit_id,
          description,
          has_stock,
          has_itbis,
          price,
          created_date,
          created_by,
          status_id
        )
        VALUES($itemTypeId,$itemCategoryId,$unitId,'$description', $hasStock,$hasItbis,$price,${DateTime.now().microsecondsSinceEpoch},$userId,1);
      """);

      return right(id);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> updateItem({
    required int id,
    required int itemTypeId,
    required int itemCategoryId,
    required int unitId,
    required String description,
    required int hasStock,
    required int hasItbis,
    required double price,
  }) async {
    try {
      final db = await AppDatabase.instance.database;

      final uid = await db.rawUpdate("""
          UPDATE items 
            SET description = ?, 
                item_type_id = ?,
                item_category_id = ?,
                unit_id = ?,
                has_stock = ?,
                has_itbis = ?,
                price = ?
          WHERE id = ?;
      """, [
        description,
        itemTypeId,
        itemCategoryId,
        unitId,
        hasStock,
        hasItbis,
        price,
        id
      ]);

      return right(uid);
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> deleteItem({required int id}) async {
    try {
      final db = await AppDatabase.instance.database;

      final did = await db.rawUpdate("""
          UPDATE items SET status_id = 3
          WHERE id = ?;
      """, [id]);

      return right(did);
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
