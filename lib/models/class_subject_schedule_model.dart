import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel {
  final String id;
  final String name;
  final String streamId;
  final String classLevel;
  final DateTime? createdAt;

  ClassModel({
    required this.id,
    required this.name,
    required this.streamId,
    required this.classLevel,
    this.createdAt,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      streamId: map['streamId'] ?? '',
      classLevel: map['classLevel'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'streamId': streamId,
      'classLevel': classLevel,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  ClassModel copyWith({
    String? id,
    String? name,
    String? streamId,
    String? classLevel,
    DateTime? createdAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      streamId: streamId ?? this.streamId,
      classLevel: classLevel ?? this.classLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class StreamModel {
  final String id;
  final String name;
  final String type;
  final String classLevel;
  final DateTime? createdAt;

  StreamModel({
    required this.id,
    required this.name,
    required this.type,
    required this.classLevel,
    this.createdAt,
  });

  factory StreamModel.fromMap(Map<String, dynamic> map) {
    return StreamModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      classLevel: map['classLevel'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'classLevel': classLevel,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  StreamModel copyWith({
    String? id,
    String? name,
    String? type,
    String? classLevel,
    DateTime? createdAt,
  }) {
    return StreamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      classLevel: classLevel ?? this.classLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SubjectModel {
  final String id;
  final String name;
  final String teacherId;
  final String classLevel;

  SubjectModel({
    required this.id,
    required this.name,
    this.teacherId = '',
    this.classLevel = '',
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      teacherId: map['teacherId'] ?? '',
      classLevel: map['classLevel'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teacherId': teacherId,
      'classLevel': classLevel,
    };
  }

  SubjectModel copyWith({
    String? id,
    String? name,
    String? teacherId,
    String? classLevel,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      classLevel: classLevel ?? this.classLevel,
    );
  }
}

class ScheduleModel {
  final String id;
  final String classId;
  final String subjectId;
  final String teacherId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? room;

  ScheduleModel({
    required this.id,
    required this.classId,
    required this.subjectId,
    required this.teacherId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'] ?? '',
      classId: map['classId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      teacherId: map['teacherId'] ?? '',
      dayOfWeek: map['dayOfWeek'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      room: map['room'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'classId': classId,
      'subjectId': subjectId,
      'teacherId': teacherId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
    };
  }
}
