import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:review_film_app/models/movie.dart';
import 'package:review_film_app/ui/providers/movie_provider.dart';
import 'package:review_film_app/ui/providers/category_provider.dart';
import 'package:review_film_app/ui/providers/user_provider.dart';
import 'package:review_film_app/ui/providers/wishlist_provider.dart';
import 'package:review_film_app/ui/screens/login_screen.dart';
import 'package:review_film_app/ui/screens/movie_details_screen.dart';
import 'package:review_film_app/ui/screens/user/profile_screen.dart';
import 'package:review_film_app/ui/screens/user/wishlist_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedLetter;
  int _currentPage = 0;
  final int _moviesPerPage = 10;
  final List<String> _alphabet = List.generate(
    26,
    (index) => String.fromCharCode(index + 65),
  );
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );

    await movieProvider.fetchMovies();
    await categoryProvider.fetchCategories();

    if (userProvider.currentUser != null) {
      await wishlistProvider.fetchWishlist(userProvider.currentUser!.id!);
    }
  }

  void _searchMovies(String query) {
    if (query.isEmpty) {
      Provider.of<MovieProvider>(context, listen: false).fetchMovies();
    } else {
      Provider.of<MovieProvider>(context, listen: false).searchMovies(query);
    }
    setState(() {
      _currentPage = 0;
      _selectedCategory = null;
      _selectedLetter = null;
    });
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      _selectedLetter = null;
      _currentPage = 0;
      _searchController.clear();
    });

    if (category == null) {
      Provider.of<MovieProvider>(context, listen: false).fetchMovies();
    } else {
      Provider.of<MovieProvider>(
        context,
        listen: false,
      ).filterMoviesByCategory(category);
    }
  }

  void _filterByLetter(String? letter) {
    setState(() {
      _selectedLetter = letter;
      _selectedCategory = null;
      _currentPage = 0;
      _searchController.clear();
    });

    if (letter == null) {
      Provider.of<MovieProvider>(context, listen: false).fetchMovies();
    } else {
      Provider.of<MovieProvider>(
        context,
        listen: false,
      ).filterMoviesByFirstLetter(letter);
    }
  }

  void _logout() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );

    userProvider.logout();
    wishlistProvider.clearWishlist();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const WishlistScreen()));
    } else if (index == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final movieProvider = Provider.of<MovieProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final theme = Theme.of(context);
    final orientation = MediaQuery.of(context).orientation;
    final size = MediaQuery.of(context).size;

    final movies = movieProvider.movies;
    final categories = categoryProvider.categories;

    // Calculate pagination
    final int totalPages = (movies.length / _moviesPerPage).ceil();
    final int startIndex = _currentPage * _moviesPerPage;
    final int endIndex =
        (startIndex + _moviesPerPage) > movies.length
            ? movies.length
            : startIndex + _moviesPerPage;

    final List<Movie> paginatedMovies =
        movies.isEmpty ? [] : movies.sublist(startIndex, endIndex);

    // Adjust poster dimensions based on orientation
    final double posterWidth = orientation == Orientation.portrait ? 120 : 100;
    final double posterHeight = orientation == Orientation.portrait ? 180 : 150;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Mục Phim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Đăng xuất'),
                      content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                          ),
                          child: const Text('Đăng xuất'),
                        ),
                      ],
                    ),
              );
            },
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Search Bar with responsive padding
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: orientation == Orientation.portrait ? 16.0 : 24.0,
                  vertical: 16.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm phim...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchMovies('');
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1,
                      ),
                    ),
                  ),
                  onSubmitted: _searchMovies,
                ),
              ),

              // Category and Alphabet filters with responsive height
              if (categories.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        orientation == Orientation.portrait ? 16.0 : 24.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'Thể loại:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: const Text('Tất cả'),
                                selected: _selectedCategory == null,
                                onSelected: (_) => _filterByCategory(null),
                                backgroundColor: Colors.grey[100],
                                selectedColor: theme.colorScheme.primary
                                    .withOpacity(0.2),
                                checkmarkColor: theme.colorScheme.primary,
                                labelStyle: TextStyle(
                                  color:
                                      _selectedCategory == null
                                          ? theme.colorScheme.primary
                                          : Colors.grey[700],
                                  fontWeight:
                                      _selectedCategory == null
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                            ...categories.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(category.name),
                                  selected: _selectedCategory == category.name,
                                  onSelected:
                                      (_) => _filterByCategory(category.name),
                                  backgroundColor: Colors.grey[100],
                                  selectedColor: theme.colorScheme.primary
                                      .withOpacity(0.2),
                                  checkmarkColor: theme.colorScheme.primary,
                                  labelStyle: TextStyle(
                                    color:
                                        _selectedCategory == category.name
                                            ? theme.colorScheme.primary
                                            : Colors.grey[700],
                                    fontWeight:
                                        _selectedCategory == category.name
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Alphabet Filter
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: orientation == Orientation.portrait ? 16.0 : 24.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Lọc theo chữ cái:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: const Text('Tất cả'),
                              selected: _selectedLetter == null,
                              onSelected: (_) => _filterByLetter(null),
                              backgroundColor: Colors.grey[100],
                              selectedColor: theme.colorScheme.primary
                                  .withOpacity(0.2),
                              checkmarkColor: theme.colorScheme.primary,
                              labelStyle: TextStyle(
                                color:
                                    _selectedLetter == null
                                        ? theme.colorScheme.primary
                                        : Colors.grey[700],
                                fontWeight:
                                    _selectedLetter == null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                          ..._alphabet.map((letter) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(letter),
                                selected: _selectedLetter == letter,
                                onSelected: (_) => _filterByLetter(letter),
                                backgroundColor: Colors.grey[100],
                                selectedColor: theme.colorScheme.primary
                                    .withOpacity(0.2),
                                checkmarkColor: theme.colorScheme.primary,
                                labelStyle: TextStyle(
                                  color:
                                      _selectedLetter == letter
                                          ? theme.colorScheme.primary
                                          : Colors.grey[700],
                                  fontWeight:
                                      _selectedLetter == letter
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Movie List with responsive layout
              Container(
                height:
                    orientation == Orientation.portrait
                        ? null
                        : MediaQuery.of(context).size.height - 200,
                child:
                    movieProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : movies.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.movie_filter_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không tìm thấy phim nào',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Thử tìm kiếm với từ khóa khác',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                        : Column(
                          children: [
                            Container(
                              height:
                                  orientation == Orientation.portrait
                                      ? MediaQuery.of(context).size.height - 300
                                      : MediaQuery.of(context).size.height -
                                          250,
                              child:
                                  orientation == Orientation.portrait
                                      ? ListView.builder(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: paginatedMovies.length,
                                        itemBuilder: (context, index) {
                                          return _buildMovieCard(
                                            context,
                                            paginatedMovies[index],
                                            userProvider,
                                            wishlistProvider,
                                            theme,
                                            posterWidth,
                                            posterHeight,
                                          );
                                        },
                                      )
                                      : GridView.builder(
                                        padding: const EdgeInsets.all(16),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount:
                                                  (size.width / 400).floor(),
                                              childAspectRatio: 2.5,
                                              mainAxisSpacing: 16,
                                              crossAxisSpacing: 16,
                                            ),
                                        itemCount: paginatedMovies.length,
                                        itemBuilder: (context, index) {
                                          return _buildMovieCard(
                                            context,
                                            paginatedMovies[index],
                                            userProvider,
                                            wishlistProvider,
                                            theme,
                                            posterWidth,
                                            posterHeight,
                                          );
                                        },
                                      ),
                            ),

                            // Pagination
                            if (totalPages > 1)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios),
                                      onPressed:
                                          _currentPage > 0
                                              ? () {
                                                setState(() {
                                                  _currentPage--;
                                                });
                                              }
                                              : null,
                                      color:
                                          _currentPage > 0
                                              ? theme.colorScheme.primary
                                              : Colors.grey[400],
                                    ),
                                    Text(
                                      'Trang ${_currentPage + 1} / $totalPages',
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_forward_ios),
                                      onPressed:
                                          _currentPage < totalPages - 1
                                              ? () {
                                                setState(() {
                                                  _currentPage++;
                                                });
                                              }
                                              : null,
                                      color:
                                          _currentPage < totalPages - 1
                                              ? theme.colorScheme.primary
                                              : Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined),
            activeIcon: Icon(Icons.movie),
            label: 'Phim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildMovieCard(
    BuildContext context,
    Movie movie,
    UserProvider userProvider,
    WishlistProvider wishlistProvider,
    ThemeData theme,
    double posterWidth,
    double posterHeight,
  ) {
    final isInWishlist =
        userProvider.currentUser != null
            ? wishlistProvider.isInWishlist(
              userProvider.currentUser!.id!,
              movie.id!,
            )
            : false;

    final orientation = MediaQuery.of(context).orientation;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster
            SizedBox(
              width: posterWidth,
              height: posterHeight,
              child:
                  movie.posterUrl.isNotEmpty
                      ? Image.network(
                        movie.posterUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.movie, color: Colors.white),
                        ),
                      ),
            ),

            // Movie Details
            Expanded(
              child: Container(
                height: posterHeight,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                movie.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                isInWishlist
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    isInWishlist
                                        ? theme.colorScheme.secondary
                                        : null,
                                size: 20,
                              ),
                              onPressed: () {
                                if (userProvider.currentUser != null) {
                                  if (isInWishlist) {
                                    wishlistProvider.removeFromWishlist(
                                      userProvider.currentUser!.id!,
                                      movie.id!,
                                    );
                                  } else {
                                    wishlistProvider.addToWishlist(
                                      userProvider.currentUser!.id!,
                                      movie.id!,
                                    );
                                  }
                                }
                              },
                              tooltip:
                                  isInWishlist
                                      ? 'Xóa khỏi danh sách yêu thích'
                                      : 'Thêm vào danh sách yêu thích',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${movie.rating}/10',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.access_time,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${movie.duration} phút',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đạo diễn: ${movie.director}',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phát hành: ${movie.releaseDate}',
                          style: theme.textTheme.bodySmall,
                        ),
                        if (orientation == Orientation.portrait) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children:
                                movie.categories
                                    .split(',')
                                    .map((category) => category.trim())
                                    .where((category) => category.isNotEmpty)
                                    .map((category) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          category,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    })
                                    .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
