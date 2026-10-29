class UsersModel {
  final int id;
  final String username;
  final String email;
  final String address;
  final String postalCode;
  final String city;
  final String country;
  final int phone;
  final String role;

  UsersModel({
    required this.id,
    required this.username,
    required this.email,
    required this.address,
    required this.postalCode,
    required this.city,
    required this.country,
    required this.phone,
    required this.role,
  });

  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      address: json['address'] ?? '',
      postalCode: json['postalCode'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      phone: json['phone'] ?? 0,
      role: json['roles'][0]['name'],
    );
  }
}
