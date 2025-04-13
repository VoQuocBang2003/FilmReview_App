class Category {
  final int? id;
  final String name;
  final String description;

  Category({this.id, required this.name, required this.description});

  // Convert a Category into a Map
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'description': description};
  }

  // Create a Category from a Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }

  Category copyWith({int? id, String? name, String? description}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
