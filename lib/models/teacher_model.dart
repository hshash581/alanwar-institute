import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherModel {
  final String uid;
  final String fullName;
  final String teacherNumber;
  final String phone;
  final String email;
  final List<String> subjectIds;
  final List<String> classLevels;
  final String? photoUrl;
  final String notes;
  final bool isActive;
  final DateTime? createdAt;

  TeacherModel({
    required this.uid,
    required this.fullName,
    required this.teacherNumber,
    required this.phone,
    required this.email,
    this.subjectIds = const [],
    this.classLevels = const [],
    this.photoUrl,
    this.notes = '',
    this.isActive = true,
    this.createdAt,
  });

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      teacherNumber: map['teacherNumber'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      subjectIds: List<String>.from(map['subjectIds'] ?? []),
      classLevels: List<String>.from(map['classLevels'] ?? []),
      photoUrl: map['photoUrl'],
      notes: map['notes'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'teacherNumber': teacherNumber,
      'phone': phone,
      'email': email,
      'subjectIds': subjectIds,
      'classLevels': classLevels,
      'photoUrl': photoUrl,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  TeacherModel copyWith({
    String? uid,
    String? fullName,
    String? teacherNumber,
    String? phone,
    String? email,
    List<String>? subjectIds,
    List<String>? classLevels,
    String? photoUrl,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return TeacherModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      teacherNumber: teacherNumber ?? this.teacherNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      subjectIds: subjectIds ?? this.subjectIds,
      classLevels: classLevels ?? this.classLevels,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
