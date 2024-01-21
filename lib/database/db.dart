import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ykjam_cargo/datas/history.dart';

class HistoryDatabase {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'ykjam_cargo.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE histories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            height REAL,
            width REAL,
            lenght REAL,
            quantity INTEGER,
            price REAL,
            date TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertHistory(History history) async {
    final db = await database;
    await db.insert('histories', history.toMap());
  }

  Future<void> removeHistory(int id) async {
    final db = await database;
    await db.delete('histories', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> removeAllHistories() async {
    final db = await database;
    await db.delete('histories');
  }
}
