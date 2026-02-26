import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CartDbHelper {
  static Database? _db;

  static Future<void> init() async {
    if (_db != null) return;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'cart.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE cart_table(
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           productName TEXT UNIQUE,
           price REAL,
           units INTEGER,
           isSynced INTEGER,
           image TEXT
        )
      ''');
    });
  }

  static Future<List<Map<String, dynamic>>> getAllRows() async {
    if (_db == null) await init();
    return await _db!.query('cart_table');
  }

  static Future<int> insertOrUpdate(String name, double price, int units,
      {required String image, int isSynced = 0}) async {
    if (_db == null) await init();
    final existing = await _db!.query(
      'cart_table',
      where: 'productName = ?',
      whereArgs: [name],
    );
    if (existing.isNotEmpty) {
      return await _db!.update(
        'cart_table',
        {'price': price, 'units': units, 'isSynced': isSynced, 'image': image},
        where: 'productName = ?',
        whereArgs: [name],
      );
    } else {
      return await _db!.insert('cart_table', {
        'productName': name,
        'price': price,
        'units': units,
        'isSynced': isSynced,
        'image': image,
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getUnsynced() async {
    if (_db == null) await init();
    return await _db!.query('cart_table', where: 'isSynced = ?', whereArgs: [0]);
  }

  static Future<void> markSynced(int id) async {
    if (_db == null) await init();
    await _db!.update('cart_table', {'isSynced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteItem(String name) async {
    if (_db == null) await init();
    await _db!.delete('cart_table', where: 'productName = ?', whereArgs: [name]);
  }

  static Future<void> updateUnits(String name, int units,
      {int isSynced = 0}) async {
    if (_db == null) await init();
    await _db!.update('cart_table', {'units': units, 'isSynced': isSynced},
        where: 'productName = ?', whereArgs: [name]);
  }
}
