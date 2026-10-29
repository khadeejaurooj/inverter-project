class DevicesListModel {
  final String macAddress;
  final String inverterName;
  final UserModel user;

  DevicesListModel({
    required this.macAddress,
    required this.inverterName,
    required this.user,
  });

  factory DevicesListModel.fromJson(Map<String, dynamic> json) {
    return DevicesListModel(
      macAddress: json["mac_address"] ?? "",
      inverterName: json["inverter_name"] ?? "",
      user: UserModel.fromJson(json["user"] ?? {}),
    );
  }
}

class UserModel {
  final int id;
  final String username;
  final String email;
  final String address;
  final String phone;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.address,
    required this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"] ?? 0,
      username: json["username"] ?? "Unknown",
      email: json["email"] ?? "N/A",
      address: json["address"] ?? "N/A",
      phone: json["phone"].toString(),
    );
  }
}
