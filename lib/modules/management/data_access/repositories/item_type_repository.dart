import 'package:dartz/dartz.dart';
import 'package:mseller/core/error/failure.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/database/database.dart';

class ItemTypeRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllItemType() async {
    try {
      final db = await AppDatabase.instance.database;

      final itemTypes = await db.rawQuery(
        "SELECT * FROM item_types WHERE status_id != 3;",
      );

      return right(itemTypes);
    } on DatabaseException catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
