import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class StateDatabaseService {
  static final StateDatabaseService instance =
      StateDatabaseService._constructor();
  static Database? _database;

  final String _tableName = "states";

  StateDatabaseService._constructor();

  Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "lead_db.db");

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            state_id INTEGER,
            state TEXT
          );
        ''');
      },
    );
    return _database!;
  }

  Future<void> insertState(Map<String, dynamic> state) async {
    final db = await getDatabase();
    await db.insert(
      _tableName,
      state,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> fetchStates() async {
    final db = await getDatabase();
    return await db.query(_tableName);
  }
}
