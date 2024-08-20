// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class StateDatabaseService {
//   static final StateDatabaseService instance =
//       StateDatabaseService._constructor();
//   static Database? _database;

//   final String _tableName = "states";

//   StateDatabaseService._constructor();

//   Future<Database> getDatabase() async {
//     if (_database != null) return _database!;
//     final databaseDirPath = await getDatabasesPath();
//     final databasePath = join(databaseDirPath, "places.db");

//     _database = await openDatabase(
//       databasePath,
//       version: 2,
//       onCreate: (db, version) async {
//         await _createTables(db);
//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         await _createTables(db);
//       },
//     );

//     return _database!;
//   }

//   Future<void> _createTables(Database db) async {
//     await db.execute('''
//       CREATE TABLE IF NOT EXISTS $_tableName (
//         id INTEGER PRIMARY KEY,
//         state TEXT
//       );
//     ''');
//   }

//   Future<void> insertState(Map<String, dynamic> state) async {
//     final db = await getDatabase();

//     // Log the data to be inserted
//     print("Inserting state: $state");

//     await db.insert(
//       _tableName,
//       state,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );

//     // Optionally, you can also fetch the data back to confirm the insertion
//     final insertedData = await db.query(
//       _tableName,
//       where: "id = ?",
//       whereArgs: [state['id']],
//     );
//     print("Inserted data: $insertedData");
//   }

//   Future<void> clearStates() async {
//     final db = await getDatabase();
//     await db.delete(_tableName);
//     print("All states have been cleared from the database.");
//   }

//   Future<List<Map<String, dynamic>>> fetchStates() async {
//     final db = await getDatabase();
//     return await db.query(_tableName);
//   }
// }
