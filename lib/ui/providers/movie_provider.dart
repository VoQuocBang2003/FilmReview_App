import 'package:flutter/foundation.dart';
import 'package:review_film_app/models/movie.dart';
import 'package:review_film_app/ui/services/database_service.dart';

class MovieProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Movie> _movies = [];
  List<Movie> _filteredMovies = [];
  bool _isLoading = false;
  bool _isFiltered = false;

  List<Movie> get movies => _isFiltered ? _filteredMovies : _movies;
  bool get isLoading => _isLoading;

  Future<void> fetchMovies() async {
    _isLoading = true;
    _isFiltered = false;
    notifyListeners();

    try {
      _movies = await _databaseService.getMovies();
    } catch (e) {
      print('Error fetching movies: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchMovies(String query) async {
    // Nếu query rỗng, reset bộ lọc (_isFiltered = false) và cập nhật UI.
    if (query.isEmpty) {
      _isFiltered = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _isFiltered = true;
    notifyListeners();

    try {
      // Nếu có từ khóa, đặt _isFiltered = true và tải danh sách phim phù hợp từ database.
      _filteredMovies = await _databaseService.searchMovies(query);
    } catch (e) {
      // Nếu lỗi xảy ra, danh sách lọc _filteredMovies sẽ trống ([]).
      print('Error searching movies: $e');
      _filteredMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterMoviesByCategory(String category) async {
    _isLoading = true;
    _isFiltered = true;
    notifyListeners();

    try {
      // Gọi filterMoviesByCategory(category) từ DatabaseService để lấy danh sách phim có thể loại mong muốn.
      _filteredMovies = await _databaseService.filterMoviesByCategory(category);
    } catch (e) {
      print('Error filtering movies by category: $e');
      _filteredMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterMoviesByFirstLetter(String letter) async {
    _isLoading = true;
    _isFiltered = true;
    notifyListeners();

    try {
      _filteredMovies = await _databaseService.filterMoviesByFirstLetter(
        letter,
      );
    } catch (e) {
      print('Error filtering movies by first letter: $e');
      _filteredMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMovie(Movie movie) async {
    _isLoading = true;
    notifyListeners();

    try {
      final id = await _databaseService.insertMovie(movie);
      final newMovie = movie.copyWith(id: id);
      _movies.add(newMovie);
    } catch (e) {
      print('Error adding movie: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMovie(Movie movie) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.updateMovie(movie);
      final index = _movies.indexWhere((m) => m.id == movie.id);
      if (index != -1) {
        _movies[index] = movie;
      }
    } catch (e) {
      print('Error updating movie: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMovie(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _databaseService.deleteMovie(id);
      _movies.removeWhere((movie) => movie.id == id);
    } catch (e) {
      print('Error deleting movie: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Movie?> getMovie(int id) async {
    try {
      return await _databaseService.getMovie(id);
    } catch (e) {
      print('Error getting movie: $e');
      return null;
    }
  }
}
