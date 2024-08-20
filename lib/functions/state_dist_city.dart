import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'location_data.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE states(
            id INTEGER PRIMARY KEY,
            name TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE districts(
            id INTEGER PRIMARY KEY,
            name TEXT,
            stateId INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE cities(
            id INTEGER PRIMARY KEY,
            name TEXT,
            districtId INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertStates(List<Map<String, dynamic>> states) async {
    final db = await database;
    for (var state in states) {
      await db.insert('states', state);
    }
    printStates();
  }

  Future<void> insertDistricts(List<Map<String, dynamic>> districts) async {
    final db = await database;
    for (var district in districts) {
      await db.insert('districts', district);
    }
    printDistricts();
  }

  Future<void> insertCities(List<Map<String, dynamic>> cities) async {
    final db = await database;
    for (var city in cities) {
      await db.insert('cities', city);
    }
    printCities();
  }

  Future<void> printStates() async {
    final db = await database;
    List<Map<String, dynamic>> states = await db.query('states');
    print('States:');
    states.forEach((state) {
      print(state);
    });
  }

  Future<void> printDistricts() async {
    final db = await database;
    List<Map<String, dynamic>> districts = await db.query('districts');
    print('Districts:');
    districts.forEach((district) {
      print(district);
    });
  }

  Future<void> printCities() async {
    final db = await database;
    List<Map<String, dynamic>> cities = await db.query('cities');
    print('Cities:');
    cities.forEach((city) {
      print(city);
    });
  }
}
