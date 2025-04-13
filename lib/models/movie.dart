class Movie {
  final int? id;
  final String title;
  final String description;
  final String director;
  final String releaseDate;
  final String posterUrl;
  final String categories;
  final bool isAgeRestricted;
  final double rating;
  final int duration; // minutes

  Movie({
    this.id,
    required this.title,
    required this.description,
    required this.director,
    required this.releaseDate,
    required this.posterUrl,
    required this.categories,
    required this.isAgeRestricted,
    required this.rating,
    required this.duration,
  });

  // Convert a Movie into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'director': director,
      'releaseDate': releaseDate,
      'posterUrl': posterUrl,
      'categories': categories,
      'isAgeRestricted': isAgeRestricted ? 1 : 0,
      'rating': rating,
      'duration': duration,
    };
  }

  // Create a Movie from a Map
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      director: map['director'],
      releaseDate: map['releaseDate'],
      posterUrl: map['posterUrl'],
      categories: map['categories'],
      isAgeRestricted: map['isAgeRestricted'] == 1,
      rating: map['rating'],
      duration: map['duration'],
    );
  }

  // Create a copy of this Movie with the given fields updated
  Movie copyWith({
    int? id,
    String? title,
    String? description,
    String? director,
    String? releaseDate,
    String? posterUrl,
    String? categories,
    bool? isAgeRestricted,
    double? rating,
    int? duration,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      director: director ?? this.director,
      releaseDate: releaseDate ?? this.releaseDate,
      posterUrl: posterUrl ?? this.posterUrl,
      categories: categories ?? this.categories,
      isAgeRestricted: isAgeRestricted ?? this.isAgeRestricted,
      rating: rating ?? this.rating,
      duration: duration ?? this.duration,
    );
  }
}
