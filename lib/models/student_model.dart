import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String uid;
  final String fullName;
  final String studentNumber;
  final String phone;
  final String email;
  final String semester;
  final String classLevel;
  final String streamId;
  final DateTime? birthDate;
  final String address;
  final String guardianName;
  final String guardianPhone;
  final List<String> subjectIds;
  final double installmentValue;
  final String notes;
  final String? photoUrl;
  final bool isActive;
  final DateTime? createdAt;

  StudentModel({
    required this.uid,
    required this.fullName,
    required this.studentNumber,
    required this.phone,
    required this.email,
    required this.semester,
    required this.classLevel,
    required this.streamId,
    this.birthDate,
    this.address = '',
    this.guardianName = '',
    this.guardianPhone = '',
    this.subjectIds = const [],
    this.installmentValue = 0,
    this.notes = '',
    this.photoUrl,
    this.isActive = true,
    this.createdAt,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      studentNumber: map['studentNumber'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      semester: map['semester'] ?? '',
      classLevel: map['classLevel'] ?? '',
      streamId: map['streamId'] ?? '',
      birthDate: (map['birthDate'] as Timestamp?)?.toDate(),
      address: map['address'] ?? '',
      guardianName: map['guardianName'] ?? '',
      guardianPhone: map['guardianPhone'] ?? '',
      subjectIds: List<String>.from(map['subjectIds'] ?? []),
      installmentValue: (map['installmentValue'] ?? 0).toDouble(),
      notes: map['notes'] ?? '',
      photoUrl: map['photoUrl'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'studentNumber': studentNumber,
      'phone': phone,
      'email': email,
      'semester': semester,
      'classLevel': classLevel,
      'streamId': streamId,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'address': address,
      'guardianName': guardianName,
      'guardianPhone': guardianPhone,
      'subjectIds': subjectIds,
      'installmentValue': installmentValue,
      'notes': notes,
      'photoUrl': photoUrl,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  StudentModel copyWith({
    String? uid,
    String? fullName,
    String? studentNumber,
    String? phone,
    String? email,
    String? semester,
    String? classLevel,
    String? streamId,
    DateTime? birthDate,
    String? address,
    String? guardianName,
    String? guardianPhone,
    List<String>? subjectIds,
    double? installmentValue,
    String? notes,
    String? photoUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return StudentModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      studentNumber: studentNumber ?? this.studentNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      semester: semester ?? this.semester,
      classLevel: classLevel ?? this.classLevel,
      streamId: streamId ?? this.streamId,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      subjectIds: subjectIds ?? this.subjectIds,
      installmentValue: installmentValue ?? this.installmentValue,
      notes: notes ?? this.notes,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
