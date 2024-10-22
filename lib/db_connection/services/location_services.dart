import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class DatabaseHelper {
  static Future<Database> _getDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'coordinates.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE coordinates(id INTEGER PRIMARY KEY AUTOINCREMENT, latitude REAL NOT NULL, longitude REAL NOT NULL, timestamp DATE DEFAULT (datetime('now','localtime')))",
        );
      },
      version: 3,
    );
  }

  static Future<void> insertCoordinate(
      double latitude, double longitude) async {
    final db = await _getDatabase();
    await db.insert(
      'coordinates',
      {'latitude': latitude, 'longitude': longitude},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> fetchCoordinates() async {
    final db = await _getDatabase();
    return await db.query('coordinates', orderBy: 'timestamp ASC');
  }

  // Add the clearCoordinates method here
  static Future<void> clearCoordinates() async {
    final db = await _getDatabase();
    await db.delete('coordinates');
  }

  void cleartable() async {
    final db = await _getDatabase();
    await db.delete('coordinates');
  }
}

class LocationService {
  Timer? _timer;
  Function(double, double)? onLocationUpdated;

  LocationService({this.onLocationUpdated});

  void startLogging() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) async {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await DatabaseHelper.insertCoordinate(
          position.latitude, position.longitude);
      if (onLocationUpdated != null) {
        onLocationUpdated!(position.latitude, position.longitude);
      }
    });
  }

  void stopLogging() {
    _timer?.cancel();
  }
}
