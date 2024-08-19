import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  static Database? _database;

  final String _tableName = "district";

  DatabaseService._constructor();

  Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "lead_db.db");

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE States (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            State_id INTEGER PRIMARY KEY AUTOINCREMENT,
            District TEXT,
          );
        ''');
      },
    );
    return _database!;
  }
}
