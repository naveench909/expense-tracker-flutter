import 'package:flutter/foundation.dart';
import '../models/category.dart' as models;
import '../services/database_service.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<models.Category> get defaultCategories =>
      _categories.where((cat) => cat.isDefault).toList();
  List<models.Category> get customCategories =>
      _categories.where((cat) => !cat.isDefault).toList();

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _databaseService.getAllCategories();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  models.Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addCategory(models.Category category) async {
    try {
      await _databaseService.createCategory(category);
      await loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCategory(models.Category category) async {
    try {
      await _databaseService.updateCategory(category);
      await loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _databaseService.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
