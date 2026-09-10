import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/core/widgets/common_cards.dart';
import 'package:alanwar_institute/models/student_model.dart';
import 'package:alanwar_institute/models/records_model.dart';


class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedReport = 'financial';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'التقارير',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildReportTab('financial', 'مالية', Icons.attach_money),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildReportTab('attendance', 'حضور', Icons.check_circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildReportTab('students', 'طلاب', Icons.people),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selectedReport == 'financial'
                  ? _buildFinancialReport()
                  : _selectedReport == 'attendance'
                      ? _buildAttendanceReport()
                      : _buildStudentReport(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTab(String value, String label, IconData icon) {
    final isSelected = _selectedReport == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedReport = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التقرير المالي الشامل',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFinancialSummary(),
          const SizedBox(height: 24),
          const Text(
            'تفاصيل بالطالب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStudentBreakdown(),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return StreamBuilder<List<StudentModel>>(
      stream: ref.watch(studentsStreamProvider).whenData((data) => Stream.value(data)).value,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }

        final students = snapshot.data ?? [];

        return StreamBuilder<List<PaymentRecord>>(
          stream: FirestoreRefs.payments.snapshots().map((snapshot) {
            return snapshot.docs.map((doc) {
              return PaymentRecord.fromMap(doc.data() as Map<String, dynamic>);
            }).toList();
          }),
          builder: (context, paymentSnapshot) {
            final payments = paymentSnapshot.data ?? [];

            final totalExpected = students.fold<double>(
              0,
              (sum, s) => sum + (s.installmentValue * 12),
            );
            final totalPaid = payments.fold<double>(
              0,
              (sum, p) => sum + p.paidAmount,
            );
            final totalRemaining = totalExpected - totalPaid;
            final collectionRate = totalExpected > 0
                ? (totalPaid / totalExpected * 100).toStringAsFixed(1)
                : '0';

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.attach_money,
                        value: '$totalExpected ل.س',
                        title: 'المتوقع',
                        iconColor: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        icon: Icons.check_circle,
                        value: '$totalPaid ل.س',
                        title: 'المتحصل',
                        iconColor: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.pending,
                        value: '$totalRemaining ل.س',
                        title: 'المتبقي',
                        iconColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        icon: Icons.percent,
                        value: '$collectionRate%',
                        title: 'نسبة التحصيل',
                        iconColor: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildBarChart(totalPaid, totalRemaining),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBarChart(double paid, double remaining) {
    final total = paid + remaining;
    final paidPercent = total > 0 ? paid / total : 0.0;
    final remainingPercent = total > 0 ? remaining / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'رسم بياني للمدفوعات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('المدفوع'),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: paidPercent,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${(paidPercent * 100).toStringAsFixed(0)}%'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('المتبقي'),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: remainingPercent,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${(remainingPercent * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentBreakdown() {
    return StreamBuilder<List<StudentModel>>(
      stream: ref.watch(studentsStreamProvider).whenData((data) => Stream.value(data)).value,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }

        final students = snapshot.data ?? [];

        return StreamBuilder<List<PaymentRecord>>(
          stream: FirestoreRefs.payments.snapshots().map((snapshot) {
            return snapshot.docs.map((doc) {
              return PaymentRecord.fromMap(doc.data() as Map<String, dynamic>);
            }).toList();
          }),
          builder: (context, paymentSnapshot) {
            final payments = paymentSnapshot.data ?? [];

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final studentPayments = payments
                    .where((p) => p.studentId == student.uid)
                    .toList();
                final totalPaid = studentPayments.fold<double>(
                  0,
                  (sum, p) => sum + p.paidAmount,
                );
                final totalExpected = student.installmentValue * 12;
                final remaining = totalExpected - totalPaid;

                PaymentStatus status;
                if (totalPaid >= totalExpected) {
                  status = PaymentStatus.paid;
                } else if (totalPaid > 0) {
                  status = PaymentStatus.partial;
                } else {
                  status = PaymentStatus.unpaid;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        student.studentNumber.substring(student.studentNumber.length - 2),
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                    title: Text(
                      student.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المتوقع: $totalExpected ل.س'),
                        Text('المدفوع: $totalPaid ل.س'),
                        Text('المتبقي: $remaining ل.س'),
                      ],
                    ),
                    trailing: StatusBadge(
                      text: _getStatusText(status),
                      color: _getStatusColor(status),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAttendanceReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تقرير الحضور والغياب',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<StudentModel>>(
            stream: ref.watch(studentsStreamProvider).whenData((data) => Stream.value(data)).value,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingView();
              }

              final students = snapshot.data ?? [];

              return StreamBuilder<List<AttendanceRecord>>(
                stream: FirestoreRefs.attendance.snapshots().map((snapshot) {
                  return snapshot.docs.map((doc) {
                    return AttendanceRecord.fromMap(doc.data() as Map<String, dynamic>);
                  }).toList();
                }),
                builder: (context, attendanceSnapshot) {
                  final attendance = attendanceSnapshot.data ?? [];

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final studentAttendance = attendance
                          .where((a) => a.studentId == student.uid)
                          .toList();
                      final presentCount = studentAttendance
                          .where((a) => a.status == AttendanceStatus.present)
                          .length;
                      final absentCount = studentAttendance
                          .where((a) => a.status == AttendanceStatus.absent)
                          .length;
                      final lateCount = studentAttendance
                          .where((a) => a.status == AttendanceStatus.late)
                          .length;
                      final total = presentCount + absentCount + lateCount;
                      final attendanceRate = total > 0
                          ? (presentCount / total * 100).toStringAsFixed(1)
                          : '0';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              student.studentNumber.substring(student.studentNumber.length - 2),
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                          title: Text(
                            student.fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('نسبة الحضور: $attendanceRate%'),
                              Row(
                                children: [
                                  _buildAttendanceChip('حضور', presentCount, Colors.green),
                                  const SizedBox(width: 4),
                                  _buildAttendanceChip('غياب', absentCount, Colors.red),
                                  const SizedBox(width: 4),
                                  _buildAttendanceChip('تأخير', lateCount, Colors.orange),
                                ],
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStudentReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تقرير الطلاب',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<StudentModel>>(
            stream: ref.watch(studentsStreamProvider).whenData((data) => Stream.value(data)).value,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingView();
              }

              final students = snapshot.data ?? [];
              final activeStudents = students.where((s) => s.isActive).length;
              final inactiveStudents = students.where((s) => !s.isActive).length;
              final totalInstallments = students.fold<double>(
                0,
                (sum, s) => sum + s.installmentValue,
              );

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.people,
                          value: '$activeStudents',
                          title: 'الطلاب النشطين',
                          iconColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icon: Icons.people_outline,
                          value: '$inactiveStudents',
                          title: 'الطلاب المعطّلين',
                          iconColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StatCard(
                    icon: Icons.attach_money,
                    value: '$totalInstallments ل.س',
                    title: 'إجمالي الأقساط الشهرية',
                    iconColor: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildStudentList(students),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<StudentModel> students) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                student.studentNumber.substring(student.studentNumber.length - 2),
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            title: Text(
              student.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المستوى: ${student.classLevel}'),
                Text('الفصل: ${student.semester}'),
              ],
            ),
            trailing: StatusBadge(
              text: student.isActive ? 'نشط' : 'معطّل',
              color: student.isActive ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.unpaid:
        return 'غير مدفوع';
      case PaymentStatus.partial:
        return 'جزئي';
      case PaymentStatus.overdue:
        return 'متأخر';
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.unpaid:
        return Colors.red;
      case PaymentStatus.partial:
        return Colors.orange;
      case PaymentStatus.overdue:
        return Colors.red;
    }
  }
}
