import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CartDbHelper {
  static Database? _db;

  static Future<void> init() async {
    if (_db != null) return;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'cart.db');
    _db = await openDatabase(path, version: 2, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE cart_table(
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           userUID TEXT NOT NULL,
           productName TEXT NOT NULL,
           price REAL,
           units INTEGER,
           isSynced INTEGER,
           image TEXT,
           UNIQUE(userUID, productName)
        )
      ''');
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        // Migrate existing data: add userUID column and clear old data
        await db.execute('DROP TABLE IF EXISTS cart_table');
        await db.execute('''
          CREATE TABLE cart_table(
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             userUID TEXT NOT NULL,
             productName TEXT NOT NULL,
             price REAL,
             units INTEGER,
             isSynced INTEGER,
             image TEXT,
             UNIQUE(userUID, productName)
          )
        ''');
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getAllRows(String userUID) async {
    if (_db == null) await init();
    return await _db!.query('cart_table', where: 'userUID = ?', whereArgs: [userUID]);
  }

  static Future<int> insertOrUpdate(String userUID, String name, double price, int units,
      {required String image, int isSynced = 0}) async {
    if (_db == null) await init();
    final existing = await _db!.query(
      'cart_table',
      where: 'userUID = ? AND productName = ?',
      whereArgs: [userUID, name],
    );
    if (existing.isNotEmpty) {
      return await _db!.update(
        'cart_table',
        {'price': price, 'units': units, 'isSynced': isSynced, 'image': image},
        where: 'userUID = ? AND productName = ?',
        whereArgs: [userUID, name],
      );
    } else {
      return await _db!.insert('cart_table', {
        'userUID': userUID,
        'productName': name,
        'price': price,
        'units': units,
        'isSynced': isSynced,
        'image': image,
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getUnsynced(String userUID) async {
    if (_db == null) await init();
    return await _db!.query('cart_table', where: 'userUID = ? AND isSynced = ?', whereArgs: [userUID, 0]);
  }

  static Future<void> markSynced(int id) async {
    if (_db == null) await init();
    await _db!.update('cart_table', {'isSynced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteItem(String userUID, String name) async {
    if (_db == null) await init();
    await _db!.delete('cart_table', where: 'userUID = ? AND productName = ?', whereArgs: [userUID, name]);
  }

  static Future<void> updateUnits(String userUID, String name, int units,
      {int isSynced = 0}) async {
    if (_db == null) await init();
    await _db!.update('cart_table', {'units': units, 'isSynced': isSynced},
        where: 'userUID = ? AND productName = ?', whereArgs: [userUID, name]);
  }

  static Future<void> clearUserCart(String userUID) async {
    if (_db == null) await init();
    await _db!.delete('cart_table', where: 'userUID = ?', whereArgs: [userUID]);
  }
}
