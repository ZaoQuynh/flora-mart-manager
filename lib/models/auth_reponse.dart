// lib/models/auth_reponse.dart
// Note: Fix the typo in the filename if needed (auth_reponse.dart -> auth_response.dart)

class AuthResponse {
  final String accessToken;
  final UserDTO user;

  AuthResponse({
    required this.accessToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] as String,
      user: UserDTO.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class UserDTO {
  final int id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? username;
  final String? tier;
  final int? points;
  final String? status;
  final String? role;
  final String? tokenRefresh;
  final String? avatar;

  UserDTO({
    required this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.username,
    this.tier,
    this.points,
    this.status,
    this.role,
    this.tokenRefresh,
    this.avatar,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] as int,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      username: json['username'] as String?,
      tier: json['tier'] as String?,
      points: json['points'] as int?,
      status: json['status'] as String?,
      role: json['role'] as String?,
      tokenRefresh: json['tokenRefresh'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}