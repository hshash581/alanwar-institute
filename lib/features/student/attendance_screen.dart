import 'package:flutter/material.dart';
import 'package:al_anwar_institute/core/constants/app_colors.dart';
import 'package:al_anwar_institute/core/services/firebase_refs.dart';
import 'package:al_anwar_institute/core/widgets/state_widgets.dart';
import 'package:al_anwar_institute/core/widgets/common_cards.dart';
import 'package:al_anwar_institute/models/student_model.dart';
import 'package:al_anwar_institute/models/records_model.dart';

class AttendanceScreen extends StatelessWidget {
  final StudentModel student;

  const AttendanceScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'سجل الحضور',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
        body: StreamBuilder<List<AttendanceRecord>>(
          stream: FirestoreRefs.attendance
              .where('studentId', isEqualTo: student.uid)
              .snapshots()
              .map((snapshot) {
            return snapshot.docs.map((doc) {
              return AttendanceRecord.fromMap(doc.data() as Map<String, dynamic>);
            }).toList();
          }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView();
            }

            if (snapshot.hasError) {
              return ErrorView(
                message: 'خطأ في تحميل البيانات',
                onRetry: () {},
              );
            }

            final records = snapshot.data ?? [];

            if (records.isEmpty) {
              return const EmptyView(
                message: 'لا توجد سجلات حضور',
                icon: Icons.check_circle_outline,
              );
            }

            final presentCount = records
                .where((r) => r.status == AttendanceStatus.present)
                .length;
            final absentCount = records
                .where((r) => r.status == AttendanceStatus.absent)
                .length;
            final lateCount = records
                .where((r) => r.status == AttendanceStatus.late)
                .length;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.check_circle,
                          value: '$presentCount',
                          title: 'حاضر',
                          iconColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icon: Icons.cancel,
                          value: '$absentCount',
                          title: 'غائب',
                          iconColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icon: Icons.access_time,
                          value: '$lateCount',
                          title: 'متأخر',
                          iconColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return _buildRecordCard(record);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecordCard(AttendanceRecord record) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (record.status) {
      case AttendanceStatus.present:
        statusColor = Colors.green;
        statusText = 'حاضر';
        statusIcon = Icons.check_circle;
        break;
      case AttendanceStatus.absent:
        statusColor = Colors.red;
        statusText = 'غائب';
        statusIcon = Icons.cancel;
        break;
      case AttendanceStatus.late:
        statusColor = Colors.orange;
        statusText = 'متأخر';
        statusIcon = Icons.access_time;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          statusText,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
        subtitle: Text(
          '${record.date.day}/${record.date.month}/${record.date.year}',
        ),
        trailing: record.note.isNotEmpty
            ? const Icon(Icons.info_outline, color: Colors.grey)
            : null,
      ),
    );
  }
}
