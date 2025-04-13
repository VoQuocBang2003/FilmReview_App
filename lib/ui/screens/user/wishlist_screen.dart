import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:review_film_app/ui/providers/user_provider.dart';
import 'package:review_film_app/ui/providers/wishlist_provider.dart';
import 'package:review_film_app/ui/screens/movie_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    _refreshWishlist();
  }

  Future<void> _refreshWishlist() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(
      context,
      listen: false,
    );

    if (userProvider.currentUser != null) {
      await wishlistProvider.fetchWishlist(userProvider.currentUser!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Danh Sách Yêu Thích')),
      body: RefreshIndicator(
        onRefresh: _refreshWishlist,
        child:
            wishlistProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : wishlistProvider.wishlistMovies.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Danh sách yêu thích của bạn đang trống.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Thêm phim vào danh sách yêu thích để xem chúng ở đây.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Duyệt Phim'),
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: wishlistProvider.wishlistMovies.length,
                  itemBuilder: (context, index) {
                    final movie = wishlistProvider.wishlistMovies[index];
                    return Dismissible(
                      key: Key('wishlist_${movie.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        await wishlistProvider.removeFromWishlist(
                          userProvider.currentUser!.id!,
                          movie.id!,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${movie.title} đã xóa khỏi danh sách yêu thích',
                            ),
                            action: SnackBarAction(
                              label: 'Hoàn tác',
                              onPressed: () async {
                                await wishlistProvider.addToWishlist(
                                  userProvider.currentUser!.id!,
                                  movie.id!,
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => MovieDetailsScreen(movie: movie),
                              ),
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Movie Poster
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                child: Image.network(
                                  movie.posterUrl,
                                  width: 100,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Container(
                                        width: 100,
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.movie,
                                          size: 50,
                                        ),
                                      ),
                                ),
                              ),

                              // Movie Details
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              movie.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              await wishlistProvider
                                                  .removeFromWishlist(
                                                    userProvider
                                                        .currentUser!
                                                        .id!,
                                                    movie.id!,
                                                  );
                                            },
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
                                            movie.rating.toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text('${movie.duration} phút'),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Đạo diễn: ${movie.director}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Phát hành: ${movie.releaseDate}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 4,
                                        children:
                                            movie.categories
                                                .split(',')
                                                .map(
                                                  (category) => Chip(
                                                    label: Text(
                                                      category.trim(),
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
