class UserProfile {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String address;

  UserProfile({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  // Mengubah dari Map SQLite ke Objek Dart (Untuk Read)
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
    );
  }

  // Mengubah dari Objek Dart ke Map SQLite (Untuk Update/Insert)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}