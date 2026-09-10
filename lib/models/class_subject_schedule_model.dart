import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String name;
  final String grade;
  final String branch;
  final DateTime? createdAt;

  ClassModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.branch,
    this.createdAt,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      grade: map['grade'] ?? '',
      branch: map['branch'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'branch': branch,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  ClassModel copyWith({
    String? id,
    String? name,
    String? grade,
    String? branch,
    DateTime? createdAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      branch: branch ?? this.branch,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SubjectModel {
  final String id;
  final String name;
  final String teacherId;
  final List<String> classIds;

  SubjectModel({
    required this.id,
    required this.name,
    this.teacherId = '',
    this.classIds = const [],
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      teacherId: map['teacherId'] ?? '',
      classIds: List<String>.from(map['classIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teacherId': teacherId,
      'classIds': classIds,
    };
  }

  SubjectModel copyWith({
    String? id,
    String? name,
    String? teacherId,
    List<String>? classIds,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      classIds: classIds ?? this.classIds,
    );
  }
}

class ScheduleModel {
  final String id;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String subjectId;
  final String subjectName;
  final String teacherId;
  final String teacherName;
  final String classId;
  final String room;

  ScheduleModel({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.subjectId,
    required this.subjectName,
    required this.teacherId,
    required this.teacherName,
    required this.classId,
    this.room = '',
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      subjectId: map['subjectId'] ?? '',
      subjectName: map['subjectName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      classId: map['classId'] ?? '',
      room: map['room'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'classId': classId,
      'room': room,
    };
  }

  ScheduleModel copyWith({
    String? id,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    String? subjectId,
    String? subjectName,
    String? teacherId,
    String? teacherName,
    String? classId,
    String? room,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      classId: classId ?? this.classId,
      room: room ?? this.room,
    );
  }
}
