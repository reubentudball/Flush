import 'package:cloud_firestore/cloud_firestore.dart';

class FlushUser {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String role;
  final DateTime createdAt;

  FlushUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.role = "user",
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "username": username,
      "email": email,
      "role": role,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  factory FlushUser.fromJson(String id, Map<String, dynamic> json) {
    return FlushUser(
      id: id,
      firstName: json["firstName"] ?? "",
      lastName: json["lastName"] ?? "",
      username: json["username"] ?? "",
      email: json["email"] ?? "",
      role: json["role"] ?? "user",
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}
