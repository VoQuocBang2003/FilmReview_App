import 'package:flutter/foundation.dart';
import 'package:review_film_app/models/wishlist.dart';
import 'package:review_film_app/models/movie.dart';
import 'package:review_film_app/ui/services/database_service.dart';

class WishlistProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  // Danh sách phim trong wishlist.
  List<Wishlist> _wishlistItems = [];
  // Danh sách phim yêu thích kèm thông tin chi tiết.
  List<Movie> _wishlistMovies = [];
  bool _isLoading = false;

  List<Wishlist> get wishlistItems => _wishlistItems;
  List<Movie> get wishlistMovies => _wishlistMovies;
  bool get isLoading => _isLoading;

  // Fetch wishlist items for a user
  Future<void> fetchWishlist(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final items = await _databaseService.getWishlistByUserId(userId);
      _wishlistItems = items;

      // Fetch the movie details for each wishlist item
      // Khởi tạo ds rỗng để lưu film có trong wishlist
      final movies = <Movie>[];
      // Duyệt qua từng mục trong ds wishlist, mỗi mục có movieId -> id film trong wishlist.
      for (var item in _wishlistItems) {
        // Gọi hàm getMovieById(movieId) từ DatabaseService để lấy chi tiết phim theo movieId
        final movie = await _databaseService.getMovieById(item.movieId);
        if (movie != null) {
          movies.add(movie);
        }
      }
      _wishlistMovies = movies;

      _isLoading = false;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      // Future.microtask() giúp nó thực hiện sau khi toàn bộ hàm kết thúc, tránh lỗi khi UI vẫn đang được build.
      Future.microtask(
        () => notifyListeners(),
      ); // Gọi notifyListeners() sau khi hoàn thành
    }
  }

  // Add movie to wishlist
  Future<bool> addToWishlist(int userId, int movieId) async {
    try {
      // Check if movie is already in wishlist
      // .any() là phương thức trả về true hoặc false khi tìm thấy ít nhất một phần tử thỏa mãn điều kiện.
      final exists = _wishlistItems.any(
        (item) => item.movieId == movieId && item.userId == userId,
      );
      if (exists) {
        return true; // Already in wishlist
      }

      final wishlistItem = Wishlist(
        userId: userId,
        movieId: movieId,
        addedAt: DateTime.now().toIso8601String(),
      );

      final id = await _databaseService.addWishlistItem(wishlistItem);
      if (id > 0) {
        _wishlistItems.add(wishlistItem.copyWith(id: id));

        // Add the movie to the wishlist movies
        final movie = await _databaseService.getMovieById(movieId);
        if (movie != null) {
          _wishlistMovies.add(movie);
        }

        Future.microtask(() => notifyListeners()); // Tránh gọi ngay trong build
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Remove movie from wishlist
  Future<bool> removeFromWishlist(int userId, int movieId) async {
    try {
      final index = _wishlistItems.indexWhere(
        (item) => item.movieId == movieId && item.userId == userId,
      );
      if (index == -1) {
        return false; // Not in wishlist
      }

      final wishlistItem = _wishlistItems[index];
      final success = await _databaseService.deleteWishlistItem(
        wishlistItem.id!,
      );

      if (success) {
        _wishlistItems.removeAt(index);

        // Remove the movie from the wishlist movies
        final movieIndex = _wishlistMovies.indexWhere(
          (movie) => movie.id == movieId,
        );
        if (movieIndex != -1) {
          _wishlistMovies.removeAt(movieIndex);
        }

        Future.microtask(
          () => notifyListeners(),
        ); // Gọi notifyListeners() sau khi hoàn thành
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Check if a movie is in the wishlist
  bool isInWishlist(int userId, int movieId) {
    return _wishlistItems.any(
      (item) => item.movieId == movieId && item.userId == userId,
    );
  }

  // Clear wishlist when user logs out
  void clearWishlist() {
    _wishlistItems = [];
    _wishlistMovies = [];
    notifyListeners();
  }
}
