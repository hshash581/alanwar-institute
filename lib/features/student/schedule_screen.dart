import 'package:flutter/material.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/models/student_model.dart';
import 'package:alanwar_institute/models/class_subject_schedule_model.dart';

class ScheduleScreen extends StatelessWidget {
  final StudentModel student;

  const ScheduleScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الجدول الدراسي',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
        body: StreamBuilder<List<ScheduleModel>>(
          stream: FirestoreRefs.schedules
              .where('classId', isEqualTo: student.streamId)
              .snapshots()
              .map((snapshot) {
            return snapshot.docs.map((doc) {
              return ScheduleModel.fromMap(doc.data() as Map<String, dynamic>);
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

            final schedules = snapshot.data ?? [];

            if (schedules.isEmpty) {
              return const EmptyView(
                message: 'لا يوجد جدول',
                icon: Icons.schedule,
              );
            }

            final groupedByDay = <String, List<ScheduleModel>>{};
            for (final schedule in schedules) {
              groupedByDay.putIfAbsent(schedule.dayOfWeek, () => []).add(schedule);
            }

            final days = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'];

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final daySchedules = groupedByDay[day] ?? [];

                if (daySchedules.isEmpty) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...daySchedules.map((schedule) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            child: const Icon(Icons.schedule, color: Colors.blue),
                          ),
                          title: Text(
                            schedule.subjectId,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${schedule.startTime} - ${schedule.endTime}',
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
