import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/receipt_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smart_receipt.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 3, 
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const userTable = '''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fullName TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL
    )
    ''';

    const receiptTable = '''
    CREATE TABLE receipts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      storeName TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      category TEXT NOT NULL,
      imagePath TEXT,
      currency TEXT DEFAULT 'RON'
    )
    ''';

    await db.execute(userTable);
    await db.execute(receiptTable);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE receipts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        storeName TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        imagePath TEXT,
        currency TEXT DEFAULT 'RON'
      )
      ''');
    }
    if (oldVersion < 3) {
      // Add currency column to existing receipts table
      try {
        await db.execute('ALTER TABLE receipts ADD COLUMN currency TEXT DEFAULT "RON"');
      } catch (e) {
        // Column already exists
      }
    }
  }

  // --- USER METHODS (MODIFICATE PENTRU NOUL FLUX) ---

  // 1. Funcție nouă: Verifică dacă există deja un utilizator (pentru auto-login)
  Future<User?> getCurrentUser() async {
    final db = await instance.database;
    // Returnăm primul utilizator găsit. Deoarece nu mai avem login, presupunem că e un singur user pe telefon.
    final maps = await db.query('users', limit: 1);
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // 2. Funcție nouă: Șterge tot (pentru butonul de Reset/Logout)
  Future<void> logoutAndClear() async {
    final db = await instance.database;
    // Ștergem utilizatorul
    await db.delete('users');
    // Ștergem și chitanțele (pentru a reseta complet aplicația)
    await db.delete('receipts');
  }

  Future<int> registerUser(User user) async {
    final db = await instance.database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      return -1;
    }
  }

  // (Păstrăm loginUser doar pentru compatibilitate, deși nu îl mai folosim direct în UI)
  Future<User?> loginUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // --- RECEIPT METHODS ---
  Future<int> addReceipt(Receipt receipt) async {
    final db = await instance.database;
    return await db.insert('receipts', receipt.toMap());
  }

  Future<List<Receipt>> getAllReceipts() async {
    final db = await instance.database;
    final result = await db.query('receipts', orderBy: 'date DESC');
    return result.map((json) => Receipt.fromMap(json)).toList();
  }

  Future<double> getTotalSpending() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM receipts');
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }
}