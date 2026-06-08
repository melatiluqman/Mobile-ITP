import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String username;
  final String role;
  final bool isAdmin;
  final bool isYard;
  final String? phone;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.isAdmin,
    required this.isYard,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        name: json['name'] as String,
        username: json['username'] as String,
        role: json['role'] as String,
        isAdmin: json['is_admin'] as bool? ?? false,
        isYard: json['is_yard'] as bool? ?? false,
        phone: json['phone'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'role': role,
        'is_admin': isAdmin,
        'is_yard': isYard,
        'phone': phone,
      };

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String s) =>
      UserModel.fromJson(jsonDecode(s) as Map<String, dynamic>);

  bool get isSuperAdmin => role == 'admin';
  bool get isAdminGalangan => role == 'admin_galangan';
  bool get isClass => role == 'class';
  bool get isOs => role == 'os';
  bool get isStat => role == 'stat';
}
