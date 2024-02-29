// import 'dart:async';
// import 'package:fleet_map_tracker/model/model.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
 

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper.internal();

//   factory DatabaseHelper() => _instance;

//      Database? _database;

//   DatabaseHelper.internal();

//   Future<Database?> get database async {
//     if (_database != null) {
//       return _database;
//     }
//     _database = await initDatabase();
//     return _database;
//   }

//   Future<Database> initDatabase() async {
//     String path = join(await getDatabasesPath(), 'locations.db');
//     return await openDatabase(path, version: 1,
//         onCreate: (Database db, int version) async {
//       await db.execute(
//           'CREATE TABLE locations(id INTEGER PRIMARY KEY, latitude REAL, longitude REAL)');
//     });
//   }

//   Future<int?> insertLocation(LocationDataModel location) async {
//     final db = await database;
//     return await db?.insert('locations', location.toMap());
//   }

//   Future<List<LocationDataModel>> getLocationHistory() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db!.query('locations');
//     return List.generate(maps.length, (i) {
//       return LocationDataModel(
//         id: maps[i]['id'],
//         latitude: maps[i]['latitude'],
//         longitude: maps[i]['longitude'],
//       );
//     });
//   }

//   Future<void> deleteAllLocations() async {
//     final db = await database;
//     await db!.delete('locations');
//   }
// }
 

