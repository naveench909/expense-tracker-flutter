import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        merchant TEXT NOT NULL,
        date TEXT NOT NULL,
        category_id TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await _seedCategories(db);
  }

  Future<void> _seedCategories(Database db) async {
    for (final entry in AppConstants.defaultCategories.entries) {
      final category = Category(
        id: entry.key,
        name: entry.value['name'] as String,
        icon: entry.value['icon'] as String,
        color: entry.value['color'] as String,
        isDefault: true,
      );
      await db.insert('categories', category.toMap());
    }
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<Category> getCategoryById(String id) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    return Category.fromMap(result.first);
  }

  Future<Category> createCategory(Category category) async {
    final db = await database;
    await db.insert('categories', category.toMap());
    return category;
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ? AND is_default = 0',
      whereArgs: [id],
    );
  }

  Future<ExpenseTransaction> createTransaction(
      ExpenseTransaction transaction) async {
    final db = await database;
    final id = await db.insert('transactions', transaction.toMap());
    return transaction.copyWith(id: id);
  }

  Future<List<ExpenseTransaction>> getAllTransactions() async {
    final db = await database;
    final result = await db.query(
      'transactions',
      orderBy: 'date DESC, created_at DESC',
    );
    return result.map((map) => ExpenseTransaction.fromMap(map)).toList();
  }

  Future<ExpenseTransaction?> getTransactionById(int id) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return ExpenseTransaction.fromMap(result.first);
  }

  Future<List<ExpenseTransaction>> getTransactionsByMonth(
      int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'date DESC',
    );
    return result.map((map) => ExpenseTransaction.fromMap(map)).toList();
  }

  Future<List<ExpenseTransaction>> getTransactionsByCategory(
      String categoryId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return result.map((map) => ExpenseTransaction.fromMap(map)).toList();
  }

  Future<List<ExpenseTransaction>> searchTransactions(String query) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'LOWER(merchant) LIKE ?',
      whereArgs: ['%${query.toLowerCase()}%'],
      orderBy: 'date DESC',
    );
    return result.map((map) => ExpenseTransaction.fromMap(map)).toList();
  }

  Future<int> updateTransaction(ExpenseTransaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalSpendingByMonth(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE date >= ? AND date <= ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getCategoryBreakdown(
      int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await db.rawQuery(
      '''
      SELECT category_id, SUM(amount) as total 
      FROM transactions 
      WHERE date >= ? AND date <= ? 
      GROUP BY category_id
      ''',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return Map.fromEntries(
      result.map((row) => MapEntry(
            row['category_id'] as String,
            (row['total'] as num).toDouble(),
          )),
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
