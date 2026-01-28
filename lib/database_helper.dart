import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'item_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shopping_list.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    // Version 5 forces update
    return await openDatabase(path, version: 5, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE items (
      id TEXT PRIMARY KEY,
      name TEXT,
      category TEXT,
      quantity REAL,
      unit TEXT,
      repeat TEXT,
      notes TEXT,
      isPurchased INTEGER,
      isPinned INTEGER, 
      priority INTEGER,
      scheduledDate TEXT,
      price REAL
    )
    ''');
    await _createRegularItemsTable(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      try {
        await db.execute("ALTER TABLE items ADD COLUMN unit TEXT DEFAULT 'pcs'");
      } catch (e) {
        // Column exists
      }
      try {
        await db.execute("ALTER TABLE items ADD COLUMN repeat TEXT DEFAULT 'None'");
      } catch (e) {
        // Column exists
      }
      try {
        await db.execute("ALTER TABLE items ADD COLUMN isPinned INTEGER DEFAULT 0");
      } catch (e) {
        // Column exists
      }
    }
    await _createRegularItemsTable(db);
  }

  Future _createRegularItemsTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS regular_items (
      id TEXT PRIMARY KEY,
      name TEXT,
      price REAL
    )
    ''');
    
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM regular_items'));
    if (count == 0) {
      await db.insert('regular_items', {'id': '1', 'name': 'Milk', 'price': 60.0});
      await db.insert('regular_items', {'id': '2', 'name': 'Bread', 'price': 40.0});
      await db.insert('regular_items', {'id': '3', 'name': 'Eggs', 'price': 100.0});
    }
  }

  Future<void> insertItem(ShoppingItem item) async {
    final db = await instance.database;
    await db.insert('items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateItem(ShoppingItem item) async {
    final db = await instance.database;
    await db.update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteItem(String id) async {
    final db = await instance.database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ShoppingItem>> getItems() async {
    final db = await instance.database;
    final result = await db.query('items');
    return result.map((json) => ShoppingItem.fromMap(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getTopFrequentItems() async {
    final db = await instance.database;
    try {
      return await db.rawQuery('SELECT name, price, COUNT(*) as count FROM items GROUP BY name ORDER BY count DESC LIMIT 5');
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getLastItemDetails(String name) async {
    final db = await instance.database;
    try {
      final result = await db.query('items', columns: ['price', 'unit', 'category'], where: 'name LIKE ?', whereArgs: [name], limit: 1, orderBy: 'scheduledDate DESC');
      if (result.isNotEmpty) return result.first;
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> insertRegularItem(String name, double price) async {
    final db = await instance.database;
    await db.insert('regular_items', {'id': DateTime.now().toString(), 'name': name, 'price': price}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteRegularItem(String id) async {
    final db = await instance.database;
    await db.delete('regular_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getRegularItems() async {
    final db = await instance.database;
    return await db.query('regular_items');
  }
}