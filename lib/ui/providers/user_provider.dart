import 'package:flutter/foundation.dart';
import 'package:review_film_app/models/user.dart';
import 'package:review_film_app/ui/services/database_service.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  User? _currentUser;
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  // Lưu thông tin người dùng hiện tại (có thể null nếu chưa đăng nhập).
  User? get currentUser => _currentUser;
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  // Kiểm tra người dùng đã đăng nhập chưa (true nếu _currentUser khác null).
  bool get isLoggedIn => _currentUser != null;
  // Kiểm tra xem người dùng có quyền admin không (true nếu _currentUser.role là "admin").
  bool get isAdmin => _currentUser?.role == 'admin';

  Future<void> fetchUsers() async {
    try {
      _isLoading = true;
      notifyListeners();

      // tìm kiếm người dùng trong database.
      final users = await _databaseService.getUsers();
      _users = users;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _databaseService.getUserByEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        _currentUser = user;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> register(User user) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if email already exists
      final existingUser = await _databaseService.getUserByEmail(user.email);
      if (existingUser != null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final userId = await _databaseService.addUser(user);
      if (userId > 0) {
        _currentUser = user.copyWith(id: userId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Xóa thông tin người dùng hiện tại và gọi notifyListeners để cập nhật UI.
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile(User updatedUser) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _databaseService.updateUser(updatedUser);

      if (success) {
        _currentUser = updatedUser;

        // Update user in the users list if it exists
        final index = _users.indexWhere((user) => user.id == updatedUser.id);
        if (index != -1) {
          _users[index] = updatedUser;
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> changePassword(
    int userId,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Verify current password
      final user = await _databaseService.getUserById(userId);
      if (user == null || user.password != currentPassword) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Update password
      final updatedUser = user.copyWith(password: newPassword);
      final success = await _databaseService.updateUser(updatedUser);

      if (success) {
        _currentUser = updatedUser;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> toggleBlockUser(User user) async {
    try {
      final updatedUser = user.copyWith(isBlocked: !user.isBlocked);
      final success = await _databaseService.updateUser(updatedUser);

      if (success) {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = updatedUser;
        }
        // Nếu người dùng hiện tại bị chặn, cập nhật luôn trạng thái
        if (_currentUser?.id == user.id) {
          _currentUser = updatedUser;
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addUser(User user) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = await _databaseService.addUser(user);

      if (userId > 0) {
        _users.add(user.copyWith(id: userId));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
