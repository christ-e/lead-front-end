import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._constructor();
  static Database? _database;

  final String _tableName = "leads";

  DatabaseService._constructor();

  Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "lead_db.db");

    _database = await openDatabase(
      databasePath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            name TEXT,
            contact_number TEXT,
            whats_app TEXT,
            email TEXT,
            address TEXT,
            state TEXT,
            district TEXT,
            city TEXT,
            location_coordinates TEXT,
            location_lat TEXT,
            location_log TEXT,
            follow_up TEXT,
            follow_up_date TEXT,  
            lead_priority TEXT,
            image_path TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db
              .execute('ALTER TABLE $_tableName ADD COLUMN user_id INTEGER;');
        }
      },
    );
    return _database!;
  }

  Future<void> deleteDatabase(String databasePath) async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "lead_db.db");
    await deleteDatabase(databasePath);
  }

  Future<int> insertLead(Map<String, dynamic> lead) async {
    final db = await getDatabase();

    // Convert DateTime to String
    if (lead.containsKey('follow_up_date') &&
        lead['follow_up_date'] is DateTime) {
      lead['follow_up_date'] =
          (lead['follow_up_date'] as DateTime).toIso8601String();
    }

    // Convert boolean values to strings
    lead['whats_app'] = lead['whats_app'] == true ? '0' : '1';
    lead['follow_up'] = lead['follow_up'] == true ? 'true' : 'false';

    return await db.insert(_tableName, lead);
  }

  Future<int> updateLead(Map<String, dynamic> lead) async {
    final db = await getDatabase();
    int id = lead['id'];

    // Convert DateTime to String
    if (lead.containsKey('follow_up_date') &&
        lead['follow_up_date'] is DateTime) {
      lead['follow_up_date'] =
          (lead['follow_up_date'] as DateTime).toIso8601String();
    }

    // Convert boolean values to strings
    lead['whats_app'] = lead['whats_app'] == true ? '1' : '0';
    lead['follow_up'] = lead['follow_up'] == true ? 'true' : 'false';

    return await db.update(
      _tableName,
      lead,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteLead(int id) async {
    final db = await getDatabase();
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllLeads() async {
    final db = await getDatabase();
    List<Map<String, dynamic>> leads = await db.query(_tableName);
    print('Fetched Leads: $leads');
    return leads;
  }

  Future<Map<String, dynamic>?> getLeadById(int id) async {
    final db = await getDatabase();
    List<Map<String, dynamic>> results = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      var lead = results.first;

      // Convert strings back to boolean
      lead['whats_app'] = lead['whats_app'] == 0;
      lead['follow_up'] = lead['follow_up'] == 'true';

      // Convert String to DateTime
      if (lead.containsKey('follow_up_date') &&
          lead['follow_up_date'] != null) {
        lead['follow_up_date'] = DateTime.parse(lead['follow_up_date']);
      }

      return lead;
    } else {
      return null;
    }
  }
}
