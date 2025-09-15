class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? role;
  final String? condominio;
  final bool isVerified;
  final String fullName;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.role,
    this.condominio,
    required this.isVerified,
    required this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'],
      condominio: json['condominio'],
      isVerified: json['is_verified'] ?? false,
      fullName: '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}',
    );
  }

  String getDisplayRole() {
    return role ?? 'Usuario';
  }

  String getDisplayCondominio() {
    return condominio ?? 'Sin condominio';
  }
}