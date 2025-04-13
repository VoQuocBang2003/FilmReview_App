class Wishlist {
  final int? id;
  final int userId;
  final int movieId;
  final String addedAt;

  Wishlist({
    this.id,
    required this.userId,
    required this.movieId,
    required this.addedAt,
  });

  // Chuyển Wishlist thành Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'userId': userId, 'movieId': movieId, 'addedAt': addedAt};
  }

  // Tạo Wishlist từ Map
  factory Wishlist.fromMap(Map<String, dynamic> map) {
    return Wishlist(
      id: map['id'],
      userId: map['userId'],
      movieId: map['movieId'],
      addedAt: map['addedAt'],
    );
  }

  // Tạo bản sao của Wishlist này với các trường được cập nhật
  Wishlist copyWith({int? id, int? userId, int? movieId, String? addedAt}) {
    return Wishlist(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
