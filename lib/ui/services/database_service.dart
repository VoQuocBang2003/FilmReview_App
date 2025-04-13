import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:review_film_app/models/movie.dart';
import 'package:review_film_app/models/user.dart';
import 'package:review_film_app/models/category.dart' as model;
import 'package:review_film_app/models/wishlist.dart';
import 'dart:io';

class DatabaseService {
  // Singleton để đảm bảo chỉ có một phiên bản DatabaseService trong ứng dụng
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static bool _initialized = false;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  // Initialize the database factory - Khởi tạo SQLite trên Android
  static Future<void> initializeDatabaseFactory() async {
    if (!_initialized) {
      print('Using default SQLite implementation for Android');
      _initialized = true;
    }
  }

  // Check if database exists and is accessible
  Future<bool> isDatabaseAccessible() async {
    try {
      print('Checking if database is accessible...');
      final db = await database;
      // Try a simple query to verify database is working - Mở database, chạy lệnh SQL đơn giản (SELECT 1) để kiểm tra database có hoạt động không.
      await db.rawQuery('SELECT 1');
      print('Database is accessible');
      return true;
    } catch (e) {
      print('Database is not accessible: $e');
      return false;
    }
  }

  // Delete and recreate the database if it's corrupted
  Future<void> resetDatabase() async {
    try {
      print('Resetting database...');
      // Close the database if it's open
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Get the database path
      String path = join(await getDatabasesPath(), 'cinema_master.db');

      // Delete the database file - Xóa file db nếu có
      if (File(path).existsSync()) {
        print('Deleting existing database file...');
        await deleteDatabase(path);
      }

      // Reinitialize the database
      _database = await _initDatabase();
      print('Database reset successful');
    } catch (e) {
      print('Error resetting database: $e');
      rethrow;
    }
  }

  // Tạo một kết nối duy nhất đến SQLite database trong ứng dụng.
  Future<Database> get database async {
    // Đã mở db --> trả về ngay để không mở lại.
    if (_database != null) return _database!;
    try {
      print('Initializing database...');
      // Make sure database factory is initialized first
      await initializeDatabaseFactory();
      // Gọi _initDatabase để tạo db nếu chưa có và kết nối đến SQLite nếu db tồn tại.
      _database = await _initDatabase();
      print('Database initialized successfully');
      return _database!;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  // Khởi tạo database
  Future<Database> _initDatabase() async {
    try {
      print('Getting database path...');
      String path = join(await getDatabasesPath(), 'cinema_master.db');
      print('Database path: $path');

      print('Opening database...');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDatabase,
        onOpen: (db) {
          print('Database opened successfully');
        },
      );
    } catch (e) {
      print('Error in _initDatabase: $e');
      rethrow;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    try {
      print('Creating database tables...');

      // Create users table
      await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          phone TEXT NOT NULL,
          password TEXT NOT NULL,
          profileImageUrl TEXT,
          isBlocked INTEGER NOT NULL DEFAULT 0,
          role TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
      print('Users table created');

      // Create categories table
      await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          description TEXT NOT NULL
        )
      ''');
      print('Categories table created');

      // Create movies table
      await db.execute('''
        CREATE TABLE movies(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          director TEXT NOT NULL,
          releaseDate TEXT NOT NULL,
          posterUrl TEXT NOT NULL,
          categories TEXT NOT NULL,
          isAgeRestricted INTEGER NOT NULL,
          rating REAL NOT NULL,
          duration INTEGER NOT NULL
        )
      ''');
      print('Movies table created');

      // Create wishlist table
      await db.execute('''
        CREATE TABLE wishlist(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          movieId INTEGER NOT NULL,
          addedAt TEXT NOT NULL,
          FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (movieId) REFERENCES movies (id) ON DELETE CASCADE,
          UNIQUE(userId, movieId)
        )
      ''');
      print('Wishlist table created');

      // Insert default admin user
      await db.insert('users', {
        'name': 'Admin',
        'email': 'admin@example.com',
        'phone': '1234567890',
        'password': 'admin123',
        'isBlocked': 0,
        'role': 'admin',
        'createdAt': DateTime.now().toIso8601String(),
      });
      print('Default admin user created');

      print('Database creation completed successfully');
    } catch (e) {
      print('Error creating database: $e');
      rethrow;
    }
  }

  // User methods
  Future<List<User>> getUsers() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('users');
      return List.generate(maps.length, (i) => User.fromMap(maps[i]));
    } catch (e) {
      print('Error in getUsers: $e');
      rethrow;
    }
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserByEmailAndPassword(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<int> addUser(User user) async {
    final db = await database;
    // Chuyển đổi User thành Map<String, dynamic> để lưu vào database.
    return await db.insert('users', user.toMap());
  }

  Future<bool> updateUser(User user) async {
    final db = await database;
    final result = await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return result > 0;
  }

  // Category methods
  Future<List<model.Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => model.Category.fromMap(maps[i]));
  }

  Future<int> insertCategory(model.Category category) async {
    return addCategory(category);
  }

  Future<int> addCategory(model.Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<bool> updateCategory(model.Category category) async {
    final db = await database;
    final result = await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
    return result > 0;
  }

  Future<bool> deleteCategory(int id) async {
    final db = await database;
    final result = await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }

  Future<model.Category?> getCategory(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return model.Category.fromMap(maps.first);
  }

  // Movie methods
  Future<List<Movie>> getMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('movies');
    return List.generate(maps.length, (i) => Movie.fromMap(maps[i]));
  }

  Future<Movie?> getMovieById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Movie.fromMap(maps.first);
  }

  Future<List<Movie>> searchMovies(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'title LIKE ? OR director LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Movie.fromMap(maps[i]));
  }

  Future<List<Movie>> filterMoviesByCategory(String category) async {
    return getMoviesByCategory(category);
  }

  Future<List<Movie>> filterMoviesByFirstLetter(String letter) async {
    return getMoviesByFirstLetter(letter);
  }

  Future<List<Movie>> getMoviesByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'categories LIKE ?',
      whereArgs: ['%$category%'],
    );
    return List.generate(maps.length, (i) => Movie.fromMap(maps[i]));
  }

  Future<List<Movie>> getMoviesByFirstLetter(String letter) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'movies',
      where: 'title LIKE ?',
      whereArgs: ['$letter%'],
    );
    return List.generate(maps.length, (i) => Movie.fromMap(maps[i]));
  }

  Future<int> insertMovie(Movie movie) async {
    return addMovie(movie);
  }

  Future<int> addMovie(Movie movie) async {
    final db = await database;
    return await db.insert('movies', movie.toMap());
  }

  Future<bool> updateMovie(Movie movie) async {
    final db = await database;
    final result = await db.update(
      'movies',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
    return result > 0;
  }

  Future<bool> deleteMovie(int id) async {
    final db = await database;
    final result = await db.delete('movies', where: 'id = ?', whereArgs: [id]);
    return result > 0;
  }

  Future<Movie?> getMovie(int id) async {
    return getMovieById(id);
  }

  // Wishlist methods
  Future<List<Wishlist>> getWishlistByUserId(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wishlist',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Wishlist.fromMap(maps[i]));
  }

  Future<int> addWishlistItem(Wishlist wishlist) async {
    final db = await database;
    return await db.insert('wishlist', wishlist.toMap());
  }

  Future<bool> deleteWishlistItem(int id) async {
    final db = await database;
    final result = await db.delete(
      'wishlist',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }
}
