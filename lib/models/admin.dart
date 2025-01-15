class Admin {
  String id;
  String name;
  String email;

  Admin ({ required this.id, required this.name, required this.email});

  factory Admin.fromMap(Map<String, dynamic> data) {
    return Admin(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}