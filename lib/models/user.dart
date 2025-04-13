class User {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final bool isBlocked;
  final String role;
  final String createdAt;
  final String? profileImageUrl;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    this.isBlocked = false,
    this.role = 'user',
    required this.createdAt,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'isBlocked': isBlocked ? 1 : 0,
      'role': role,
      'createdAt': createdAt,
      'profileImageUrl': profileImageUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      password: map['password'],
      isBlocked: map['isBlocked'] == 1,
      role: map['role'],
      createdAt: map['createdAt'],
      profileImageUrl: map['profileImageUrl'],
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? password,
    bool? isBlocked,
    String? role,
    String? createdAt,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      isBlocked: isBlocked ?? this.isBlocked,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
