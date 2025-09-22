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
  final int? propietarioId;

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
    this.propietarioId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role_name'], // Usar role_name que es String
      condominio: json['condominio_name'], // Usar condominio_name que es String
      isVerified: json['is_verified'] ?? false,
      fullName: '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}',
      propietarioId: json['propietario_id'],
    );
  }

  String getDisplayRole() {
    return role ?? 'Usuario';
  }

  String getDisplayCondominio() {
    return condominio ?? 'Sin condominio';
  }
}