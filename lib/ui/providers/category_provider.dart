import 'package:flutter/foundation.dart';
import 'package:review_film_app/models/category.dart' as model;
import 'package:review_film_app/ui/services/database_service.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<model.Category> _categories = [];
  bool _isLoading = false;

  List<model.Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _databaseService.getCategories();
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(model.Category category) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _databaseService.insertCategory(category);
      final newCategory = category.copyWith(id: id);
      _categories.add(newCategory);
    } catch (e) {
      print('Error adding category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(model.Category category) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
      }
    } catch (e) {
      print('Error updating category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.deleteCategory(id);
      _categories.removeWhere((category) => category.id == id);
    } catch (e) {
      print('Error while deleting category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<model.Category?> getCategory(int id) async {
    try {
      return await _databaseService.getCategory(id);
    } catch (e) {
      print('Error while getting category: $e');
      return null;
    }
  }
}
