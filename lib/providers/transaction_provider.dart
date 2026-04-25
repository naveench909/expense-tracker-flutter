import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<ExpenseTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<ExpenseTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _databaseService.getAllTransactions();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransactionsByMonth(int year, int month) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _databaseService.getTransactionsByMonth(year, month);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ExpenseTransaction> getRecentTransactions({int limit = 10}) {
    return _transactions.take(limit).toList();
  }

  Future<void> addTransaction(ExpenseTransaction transaction) async {
    try {
      await _databaseService.createTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTransaction(ExpenseTransaction transaction) async {
    try {
      await _databaseService.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _databaseService.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> searchTransactions(String query) async {
    if (query.isEmpty) {
      await loadTransactions();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _databaseService.searchTransactions(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<double> getMonthlyTotal(int year, int month) async {
    return await _databaseService.getTotalSpendingByMonth(year, month);
  }

  Future<Map<String, double>> getCategoryBreakdown(int year, int month) async {
    return await _databaseService.getCategoryBreakdown(year, month);
  }

  List<ExpenseTransaction> filterByCategory(String categoryId) {
    return _transactions
        .where((transaction) => transaction.categoryId == categoryId)
        .toList();
  }

  List<ExpenseTransaction> filterByPaymentMethod(String paymentMethod) {
    return _transactions
        .where((transaction) => transaction.paymentMethod == paymentMethod)
        .toList();
  }
}
