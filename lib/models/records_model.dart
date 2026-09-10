import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus { present, absent, late }

enum PaymentStatus { paid, unpaid, partial, overdue }

enum AnnouncementTarget { all, classId, subject, teachers }

class AttendanceRecord {
  final String id;
  final String studentId;
  final String classId;
  final String subjectId;
  final String scheduleId;
  final DateTime date;
  final AttendanceStatus status;
  final String note;
  final String recordedBy;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.subjectId,
    required this.scheduleId,
    required this.date,
    required this.status,
    this.note = '',
    required this.recordedBy,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      classId: map['classId'] ?? '',
      subjectId: map['subjectId'] ?? '',
      scheduleId: map['scheduleId'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _parseAttendanceStatus(map['status']),
      note: map['note'] ?? '',
      recordedBy: map['recordedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'classId': classId,
      'subjectId': subjectId,
      'scheduleId': scheduleId,
      'date': Timestamp.fromDate(date),
      'status': status.name,
      'note': note,
      'recordedBy': recordedBy,
    };
  }

  static AttendanceStatus _parseAttendanceStatus(String? status) {
    switch (status) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      default:
        return AttendanceStatus.absent;
    }
  }
}

class PaymentTransaction {
  final double amount;
  final DateTime date;
  final String recordedBy;
  final String? note;

  PaymentTransaction({
    required this.amount,
    required this.date,
    required this.recordedBy,
    this.note,
  });

  factory PaymentTransaction.fromMap(Map<String, dynamic> map) {
    return PaymentTransaction(
      amount: (map['amount'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      recordedBy: map['recordedBy'] ?? '',
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'recordedBy': recordedBy,
      'note': note,
    };
  }
}

class PaymentRecord {
  final String id;
  final String studentId;
  final double totalValue;
  final double paidAmount;
  final DateTime? dueDate;
  final PaymentStatus status;
  final List<PaymentTransaction> transactions;
  final String notes;

  PaymentRecord({
    required this.id,
    required this.studentId,
    required this.totalValue,
    this.paidAmount = 0,
    this.dueDate,
    required this.status,
    this.transactions = const [],
    this.notes = '',
  });

  double get remaining => totalValue - paidAmount;

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    final transactionsData = map['transactions'] as List<dynamic>? ?? [];
    final transactions = transactionsData
        .map((t) => PaymentTransaction.fromMap(t as Map<String, dynamic>))
        .toList();
    return PaymentRecord(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      totalValue: (map['totalValue'] ?? 0).toDouble(),
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      status: _parsePaymentStatus(map['status']),
      transactions: transactions,
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'totalValue': totalValue,
      'paidAmount': paidAmount,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'status': status.name,
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'notes': notes,
    };
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
      case 'paid':
        return PaymentStatus.paid;
      case 'unpaid':
        return PaymentStatus.unpaid;
      case 'partial':
        return PaymentStatus.partial;
      case 'overdue':
        return PaymentStatus.overdue;
      default:
        return PaymentStatus.unpaid;
    }
  }
}

class AssignmentModel {
  final String id;
  final String subjectId;
  final String classId;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String? fileUrl;
  final String createdBy;
  final DateTime? createdAt;

  AssignmentModel({
    required this.id,
    required this.subjectId,
    required this.classId,
    required this.title,
    this.description = '',
    this.dueDate,
    this.fileUrl,
    required this.createdBy,
    this.createdAt,
  });

  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      id: map['id'] ?? '',
      subjectId: map['subjectId'] ?? '',
      classId: map['classId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      fileUrl: map['fileUrl'],
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'classId': classId,
      'title': title,
      'description': description,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'fileUrl': fileUrl,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}

class AnnouncementModel {
  final String id;
  final String title;
  final String body;
  final AnnouncementTarget target;
  final String? targetValue;
  final String createdBy;
  final DateTime? createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    this.targetValue,
    required this.createdBy,
    this.createdAt,
  });

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      target: _parseAnnouncementTarget(map['target']),
      targetValue: map['targetValue'],
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'target': target.name,
      'targetValue': targetValue,
      'createdBy': createdBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  static AnnouncementTarget _parseAnnouncementTarget(String? target) {
    switch (target) {
      case 'all':
        return AnnouncementTarget.all;
      case 'classId':
        return AnnouncementTarget.classId;
      case 'subject':
        return AnnouncementTarget.subject;
      case 'teachers':
        return AnnouncementTarget.teachers;
      default:
        return AnnouncementTarget.all;
    }
  }
}
