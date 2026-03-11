import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vehicle.dart';

/// Singleton database service using sqflite
class DatabaseService {
  static DatabaseService? _instance;
  static Database? _database;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Get the database instance (lazy initialization)
  Future<Database> get db async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'revora_vehicles.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE vehicles(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            brand TEXT NOT NULL,
            model TEXT NOT NULL,
            year INTEGER NOT NULL,
            nickname TEXT,
            isSelected INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ===================== VEHICLE OPERATIONS =====================

  /// Get all saved vehicles
  Future<List<Vehicle>> getAllVehicles() async {
    final database = await db;
    final maps = await database.query('vehicles', orderBy: 'createdAt DESC');
    return maps.map((m) => Vehicle.fromMap(m)).toList();
  }

  /// Get the currently selected vehicle
  Future<Vehicle?> getSelectedVehicle() async {
    final database = await db;
    final maps = await database.query(
      'vehicles',
      where: 'isSelected = ?',
      whereArgs: [1],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Vehicle.fromMap(maps.first);
  }

  /// Add a new vehicle
  Future<int> addVehicle(Vehicle vehicle) async {
    final database = await db;
    return database.insert('vehicles', vehicle.toMap());
  }

  /// Update an existing vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    final database = await db;
    await database.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  /// Delete a vehicle by ID
  Future<bool> deleteVehicle(int id) async {
    final database = await db;
    final count = await database.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  /// Select a vehicle (deselect all others first)
  Future<void> selectVehicle(int vehicleId) async {
    final database = await db;
    await database.transaction((txn) async {
      // Deselect all
      await txn.update('vehicles', {'isSelected': 0});
      // Select the target
      await txn.update(
        'vehicles',
        {'isSelected': 1},
        where: 'id = ?',
        whereArgs: [vehicleId],
      );
    });
  }

  /// Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
