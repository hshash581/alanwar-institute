import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, teacher, student }

class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String username;
  final UserRole role;
  final bool isActive;
  final String? photoUrl;
  final String? fcmToken;
  final DateTime? createdAt;
  final String? createdBy;

  AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.username,
    required this.role,
    this.isActive = true,
    this.photoUrl,
    this.fcmToken,
    this.createdAt,
    this.createdBy,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      role: _parseRole(map['role']),
      isActive: map['isActive'] ?? true,
      photoUrl: map['photoUrl'],
      fcmToken: map['fcmToken'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      createdBy: map['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'username': username,
      'role': role.name,
      'isActive': isActive,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'createdBy': createdBy,
    };
  }

  static UserRole _parseRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'teacher':
        return UserRole.teacher;
      case 'student':
        return UserRole.student;
      default:
        return UserRole.student;
    }
  }

  AppUser copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? username,
    UserRole? role,
    bool? isActive,
    String? photoUrl,
    String? fcmToken,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
