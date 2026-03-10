class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'createdAt': createdAt.toIso8601String(),
      };
}

class DeliveryAgent extends User {
  final int companyId;

  DeliveryAgent({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.createdAt,
    required this.companyId,
  });
}
