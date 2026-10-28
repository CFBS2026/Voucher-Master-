import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'voucher_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vouchers.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vouchers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL,
        profileName TEXT NOT NULL,
        price REAL NOT NULL,
        generatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertVoucher(Voucher voucher) async {
    final db = await instance.database;
    return await db.insert('vouchers', voucher.toMap());
  }

  Future<List<Voucher>> getAllVouchers() async {
    final db = await instance.database;
    final result = await db.query('vouchers', orderBy: 'id DESC');
    return result.map((json) => Voucher.fromMap(json)).toList();
  }

  Future<double> getTotalRevenue() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(price) as total FROM vouchers');
    if (result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }
}
