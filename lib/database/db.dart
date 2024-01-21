import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ykjam_cargo/datas/history.dart';

class SqliteService {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'ykjamCargo.db'),
      onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE histories (id INTEGER PRIMARY KEY AUTOINCREMENT, height REAL, width REAL, lenght REAL, quantity INTEGER, price REAL, date TEXT);");
      },
      version: 1,
    );
  }

  Future<void> createHistory(History history) async {
    final db = await initializeDB();

    await db.insert(
      "histories",
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Future<List<History>> getHistories() async {
  //   final db = await initializeDB();

  //   final List<Map<String, Object?>> queryResult =
  //       await db.query("histories", orderBy: "date");

  //       return queryResult.map((e) => null)
  // }
}
