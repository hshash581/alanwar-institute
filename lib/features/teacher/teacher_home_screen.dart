import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/routing/role_scaffold.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/core/widgets/common_cards.dart';
import 'package:alanwar_institute/core/widgets/dashboard_header.dart';
import 'package:alanwar_institute/features/teacher/class_attendance_screen.dart';
import 'package:alanwar_institute/models/class_subject_schedule_model.dart';
import 'package:alanwar_institute/models/student_model.dart';
import 'package:alanwar_institute/models/records_model.dart';
import 'package:alanwar_institute/models/teacher_model.dart';

class TeacherHomeScreen extends ConsumerStatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  ConsumerState<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends ConsumerState<TeacherHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentAppUserProvider);

    return currentUser.when(
      data: (user) {
        if (user == null) {
          return const Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Center(
                child: Text(
                  'يرجى تسجيل الدخول',
                  style: TextStyle(fontSize: 18, color: AppColors.subtitleText),
                ),
              ),
            ),
          );
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: [
                _buildDashboardTab(user.uid),
                _buildScheduleTab(user.uid),
                _buildStudentsTab(user.uid),
                _buildSubjectsTab(user.uid),
                _buildMoreTab(user),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home_rounded, 'الرئيسية'),
                      _buildNavItem(1, Icons.schedule_rounded, 'حصصي'),
                      _buildNavItem(2, Icons.people_rounded, 'الطلاب'),
                      _buildNavItem(3, Icons.book_rounded, 'المواد'),
                      _buildNavItem(4, Icons.more_horiz_rounded, 'المزيد'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: LoadingView()),
      ),
      error: (_, __) => const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: ErrorView(message: 'خطأ في تحميل البيانات')),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.mediumGray,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTodayName() {
    final now = DateTime.now();
    switch (now.weekday) {
      case 6:
        return 'السبت';
      case 7:
        return 'الأحد';
      case 1:
        return 'الاثنين';
      case 2:
        return 'الثلاثاء';
      case 3:
        return 'الأربعاء';
      case 4:
        return 'الخميس';
      case 5:
        return 'الجمعة';
      default:
        return 'السبت';
    }
  }

  Widget _buildDashboardTab(String teacherId) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(teacherId),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildStatsRow(teacherId),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'جدول اليوم',
                  actionText: 'عرض الكل',
                  onActionTap: () => setState(() => _currentIndex = 1),
                ),
                const SizedBox(height: 12),
                _buildTodaySchedule(teacherId),
                const SizedBox(height: 24),
                SectionHeader(title: 'حصصي القادمة'),
                const SizedBox(height: 12),
                _buildUpcomingClasses(teacherId),
                const SizedBox(height: 24),
                SectionHeader(title: 'أدوات سريعة'),
                const SizedBox(height: 12),
                _buildQuickActions(teacherId),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'آخر الإعلانات',
                  actionText: 'عرض الكل',
                ),
                const SizedBox(height: 12),
                _buildRecentAnnouncements(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String teacherId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirestoreRefs.teachers.doc(teacherId).snapshots(),
      builder: (context, snapshot) {
        String teacherName = '';
        String subjectInfo = '';

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            teacherName = data['fullName'] ?? '';
            final subjectIds = List<String>.from(data['subjectIds'] ?? []);
            if (subjectIds.isNotEmpty) {
              subjectInfo = '${subjectIds.length} مواد';
            }
          }
        }

        return DashboardHeader(
          greeting: 'مرحباً بك',
          name: teacherName.isNotEmpty ? teacherName : 'المعلم',
          subtitle: subjectInfo.isNotEmpty ? subjectInfo : 'معهد الأنوار',
          role: 'معلم',
          onNotificationTap: () {},
          showNotification: true,
        );
      },
    );
  }

  Widget _buildStatsRow(String teacherId) {
    return StreamBuilder<List<StudentModel>>(
      stream: ref.watch(studentsStreamProvider).whenData((data) => Stream.value(data)).value,
      builder: (context, studentSnapshot) {
        final allStudents = studentSnapshot.data ?? [];
        final studentsCount = allStudents.where((s) => s.isActive).length;

        return StreamBuilder<List<SubjectModel>>(
          stream: ref.watch(subjectsStreamProvider).whenData((data) => Stream.value(data)).value,
          builder: (context, subjectSnapshot) {
            final allSubjects = subjectSnapshot.data ?? [];
            final subjectsCount = allSubjects.length;

            return StreamBuilder<List<ScheduleModel>>(
              stream: FirestoreRefs.schedules
                  .where('teacherId', isEqualTo: teacherId)
                  .snapshots()
                  .map((snapshot) {
                return snapshot.docs.map((doc) {
                  return ScheduleModel.fromMap(doc.data() as Map<String, dynamic>);
                }).toList();
              }),
              builder: (context, scheduleSnapshot) {
                final schedules = scheduleSnapshot.data ?? [];

                return StreamBuilder<List<AnnouncementModel>>(
                  stream: FirestoreRefs.announcements.snapshots().map((snapshot) {
                    return snapshot.docs.map((doc) {
                      return AnnouncementModel.fromMap(doc.data() as Map<String, dynamic>);
                    }).toList();
                  }),
                  builder: (context, announcementSnapshot) {
                    final announcements = announcementSnapshot.data ?? [];
                    final todayName = _getTodayName();
                    final todayScheduleCount = schedules.where((s) => s.dayOfWeek == todayName).length;

                    return Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.people_rounded,
                            value: '$studentsCount',
                            title: 'الطلاب',
                            iconColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.book_rounded,
                            value: '$subjectsCount',
                            title: 'المواد',
                            iconColor: AppColors.success,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTodaySchedule(String teacherId) {
    final todayName = _getTodayName();

    return StreamBuilder<List<ScheduleModel>>(
      stream: FirestoreRefs.schedules
          .where('teacherId', isEqualTo: teacherId)
          .where('dayOfWeek', isEqualTo: todayName)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ScheduleModel.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (snapshot.hasError) {
          return const EmptyState(
            icon: Icons.error_outline,
            message: 'خطأ في تحميل الجدول',
          );
        }

        final schedules = snapshot.data ?? [];

        if (schedules.isEmpty) {
          return const EmptyState(
            icon: Icons.event_busy_rounded,
            message: 'لا توجد حصص مجدولة اليوم',
          );
        }

        return Column(
          children: schedules.map((schedule) {
            return _buildScheduleCardFromData(schedule);
          }).toList(),
        );
      },
    );
  }

  Widget _buildScheduleCardFromData(ScheduleModel schedule) {
    return StreamBuilder<List<SubjectModel>>(
      stream: ref.watch(subjectsStreamProvider).whenData((data) => Stream.value(data)).value,
      builder: (context, subjectSnapshot) {
        final subjects = subjectSnapshot.data ?? [];
        final subject = subjects.firstWhere(
          (s) => s.id == schedule.subjectId,
          orElse: () => SubjectModel(id: '', name: schedule.subjectId),
        );

        return StreamBuilder<List<ClassModel>>(
          stream: ref.watch(classesStreamProvider).whenData((data) => Stream.value(data)).value,
          builder: (context, classSnapshot) {
            final classes = classSnapshot.data ?? [];
            final classModel = classes.firstWhere(
              (c) => c.id == schedule.classId,
              orElse: () => ClassModel(id: '', name: schedule.classId, streamId: '', classLevel: ''),
            );

            return ScheduleCard(
              subject: subject.name,
              time: '${schedule.startTime} - ${schedule.endTime}',
              details: classModel.name,
              room: schedule.room,
              color: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClassAttendanceScreen(
                      classId: schedule.classId,
                      subjectId: schedule.subjectId,
                      scheduleId: schedule.id,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUpcomingClasses(String teacherId) {
    return StreamBuilder<List<ScheduleModel>>(
      stream: FirestoreRefs.schedules
          .where('teacherId', isEqualTo: teacherId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ScheduleModel.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (snapshot.hasError) {
          return const EmptyState(
            icon: Icons.error_outline,
            message: 'خطأ في تحميل الحصص',
          );
        }

        final schedules = snapshot.data ?? [];

        if (schedules.isEmpty) {
          return const EmptyState(
            icon: Icons.event_available_rounded,
            message: 'لا توجد حصص قادمة',
          );
        }

        final todayName = _getTodayName();
        final upcomingSchedules = schedules.where((s) => s.dayOfWeek != todayName).toList();
        final dayOrder = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
        final todayIndex = dayOrder.indexOf(todayName);

        upcomingSchedules.sort((a, b) {
          final aIndex = dayOrder.indexOf(a.dayOfWeek);
          final bIndex = dayOrder.indexOf(b.dayOfWeek);
          final aAdjusted = (aIndex - todayIndex + 7) % 7;
          final bAdjusted = (bIndex - todayIndex + 7) % 7;
          return aAdjusted.compareTo(bAdjusted);
        });

        if (upcomingSchedules.isEmpty) {
          return const EmptyState(
            icon: Icons.event_available_rounded,
            message: 'لا توجد حصص قادمة',
          );
        }

        return Column(
          children: upcomingSchedules.take(5).map((schedule) {
            return _buildScheduleCardFromData(schedule);
          }).toList(),
        );
      },
    );
  }

  Widget _buildQuickActions(String teacherId) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.how_to_reg_rounded,
                title: 'تسجيل الحضور',
                subtitle: 'تسجيل حضور الطلاب',
                iconColor: AppColors.success,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                icon: Icons.assignment_rounded,
                title: 'إضافة واجب',
                subtitle: 'إضافة واجب جديد',
                iconColor: AppColors.warning,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.group_rounded,
                title: 'طلاب الشعبة',
                subtitle: 'عرض قائمة الطلاب',
                iconColor: AppColors.primary,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                icon: Icons.campaign_rounded,
                title: 'إرسال إعلان',
                subtitle: 'نشر إعلان جديد',
                iconColor: AppColors.info,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentAnnouncements() {
    return StreamBuilder<List<AnnouncementModel>>(
      stream: FirestoreRefs.announcements
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return AnnouncementModel.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }

        if (snapshot.hasError) {
          return const EmptyState(
            icon: Icons.error_outline,
            message: 'خطأ في تحميل الإعلانات',
          );
        }

        final announcements = snapshot.data ?? [];

        if (announcements.isEmpty) {
          return const EmptyState(
            icon: Icons.campaign_outlined,
            message: 'لا توجد إعلانات حديثة',
          );
        }

        return Column(
          children: announcements.map((announcement) {
            final dateStr = announcement.createdAt != null
                ? '${announcement.createdAt!.day}/${announcement.createdAt!.month}/${announcement.createdAt!.year}'
                : '';

            return AnnouncementCard(
              title: announcement.title,
              body: announcement.body,
              date: dateStr,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildScheduleTab(String teacherId) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.schedule_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'جدول حصصي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ScheduleModel>>(
            stream: FirestoreRefs.schedules
                .where('teacherId', isEqualTo: teacherId)
                .snapshots()
                .map((snapshot) {
              return snapshot.docs.map((doc) {
                return ScheduleModel.fromMap(doc.data() as Map<String, dynamic>);
              }).toList();
            }),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (snapshot.hasError) {
                return const EmptyState(
                  icon: Icons.error_outline,
                  message: 'خطأ في تحميل الجدول',
                );
              }

              final schedules = snapshot.data ?? [];

              if (schedules.isEmpty) {
                return const EmptyState(
                  icon: Icons.event_busy_rounded,
                  message: 'لا توجد حصص مجدولة',
                );
              }

              final dayOrder = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
              final grouped = <String, List<ScheduleModel>>{};
              for (final schedule in schedules) {
                grouped.putIfAbsent(schedule.dayOfWeek, () => []).add(schedule);
              }

              final sortedDays = dayOrder.where((day) => grouped.containsKey(day)).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: sortedDays.length,
                itemBuilder: (context, index) {
                  final day = sortedDays[index];
                  final daySchedules = grouped[day]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      ...daySchedules.map((schedule) {
                        return _buildScheduleCardFromData(schedule);
                      }),
                      if (index < sortedDays.length - 1) const SizedBox(height: 16),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentsTab(String teacherId) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.people_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'طلابي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<StudentModel>>(
            stream: ref.watch(studentsStreamProvider).whenData((data) => Stream.value(data)).value,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (snapshot.hasError) {
                return const EmptyState(
                  icon: Icons.error_outline,
                  message: 'خطأ في تحميل بيانات الطلاب',
                );
              }

              final allStudents = snapshot.data ?? [];
              final students = allStudents.where((s) => s.isActive).toList();

              if (students.isEmpty) {
                return const EmptyState(
                  icon: Icons.people_outline,
                  message: 'لا يوجد طلاب مسجلين',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  return _buildStudentCard(student);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(StudentModel student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              student.fullName.isNotEmpty ? student.fullName[0] : '?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'رقم الطالب: ${student.studentNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.subtitleText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'الفصل: ${student.classLevel}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.subtitleText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_left,
            color: AppColors.mediumGray,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsTab(String teacherId) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.book_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'المواد الدراسية',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<SubjectModel>>(
            stream: ref.watch(subjectsStreamProvider).whenData((data) => Stream.value(data)).value,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (snapshot.hasError) {
                return const EmptyState(
                  icon: Icons.error_outline,
                  message: 'خطأ في تحميل المواد',
                );
              }

              final subjects = snapshot.data ?? [];

              if (subjects.isEmpty) {
                return const EmptyState(
                  icon: Icons.book_outlined,
                  message: 'لا توجد مواد دراسية',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return _buildSubjectCard(subject);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(SubjectModel subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.book_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'المستوى: ${subject.classLevel}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.subtitleText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_left,
            color: AppColors.mediumGray,
          ),
        ],
      ),
    );
  }

  Widget _buildMoreTab(dynamic user) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'معلم',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildProfileMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'الملف الشخصي',
            subtitle: 'عرض وتعديل البيانات الشخصية',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'الإشعارات',
            subtitle: 'إدارة الإشعارات',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.lock_outline_rounded,
            title: 'تغيير كلمة المرور',
            subtitle: 'تحديث كلمة المرور',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'المساعدة',
            subtitle: 'الدعم الفني',
            onTap: () {},
          ),
          _buildProfileMenuItem(
            icon: Icons.info_outline_rounded,
            title: 'عن المعهد',
            subtitle: 'معلومات عن معهد الأنوار',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      title: const Text('تأكيد تسجيل الخروج'),
                      content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'تسجيل الخروج',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                if (confirmed == true) {
                  ref.read(authServiceProvider).signOut();
                }
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.subtitleText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_left,
                  color: AppColors.mediumGray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
