import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/routing/role_scaffold.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/core/widgets/common_cards.dart';
import 'package:alanwar_institute/core/widgets/dashboard_header.dart';
import 'package:alanwar_institute/features/student/payments_screen.dart';
import 'package:alanwar_institute/features/student/attendance_screen.dart';
import 'package:alanwar_institute/features/student/schedule_screen.dart';
import 'package:alanwar_institute/features/student/profile_screen.dart';
import 'package:alanwar_institute/features/student/subjects_screen.dart';
import 'package:alanwar_institute/features/student/assignments_screen.dart';
import 'package:alanwar_institute/features/student/announcements_screen.dart';
import 'package:alanwar_institute/models/student_model.dart';
import 'package:alanwar_institute/models/records_model.dart';
import 'package:alanwar_institute/models/class_subject_schedule_model.dart';

class StudentHomeScreen extends ConsumerStatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  ConsumerState<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends ConsumerState<StudentHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentAppUserProvider);

    return currentUser.when(
      data: (user) {
        if (user == null) return const LoginScreenPlaceholder();

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.lightGray,
            body: StreamBuilder<List<StudentModel>>(
              stream: FirestoreRefs.students
                  .where('uid', isEqualTo: user.uid)
                  .snapshots()
                  .map((snapshot) {
                return snapshot.docs.map((doc) {
                  return StudentModel.fromMap(doc.data() as Map<String, dynamic>);
                }).toList();
              }),
              builder: (context, studentSnapshot) {
                final students = studentSnapshot.data ?? [];
                final student = students.isNotEmpty ? students.first : null;

                return IndexedStack(
                  index: _currentIndex,
                  children: [
                    _buildHomeTab(user, student),
                    _buildPaymentsTab(student),
                    _buildAttendanceTab(student),
                    _buildScheduleTab(student),
                    _buildProfileTab(user),
                  ],
                );
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.payment_rounded),
                  activeIcon: Icon(Icons.payment_rounded),
                  label: 'الأقساط',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  activeIcon: Icon(Icons.check_circle),
                  label: 'الحضور',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.schedule_rounded),
                  activeIcon: Icon(Icons.schedule_rounded),
                  label: 'البرنامج',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'حسابي',
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, __) => const Scaffold(body: ErrorView(message: 'خطأ')),
    );
  }

  Widget _buildHomeTab(dynamic user, StudentModel? student) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(
            greeting: 'مرحباً بك',
            name: user.displayName ?? 'طالب',
            subtitle: student != null
                ? '${student.classLevel} - ${student.semester}'
                : 'معهد الأنوار',
            role: 'طالب',
            onNotificationTap: () {},
            showNotification: true,
          ),
          const SizedBox(height: 16),
          _buildEducationalBanner(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(
              title: 'ملخص سريع',
            ),
          ),
          const SizedBox(height: 12),
          _buildStatsSection(student),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(
              title: 'الاختصارات السريعة',
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickActionsGrid(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildProfileCard(user, student),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(
              title: 'آخر الإعلانات',
              actionText: 'عرض الكل',
              onActionTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnnouncementsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildLatestAnnouncements(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEducationalBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A3A6E), Color(0xFF2E5BFF), Color(0xFF5B8DFF)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_stories,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'بالعلم نبني مستقبلنا',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'استمر في التعلم والاجتهاد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(StudentModel? student) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<List<ScheduleModel>>(
        stream: FirestoreRefs.schedules
            .where('classId', isEqualTo: student?.streamId ?? '')
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ScheduleModel.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();
        }),
        builder: (context, scheduleSnapshot) {
          final schedules = scheduleSnapshot.data ?? [];
          final todayName = _getTodayName();
          final todayClasses =
              schedules.where((s) => s.dayOfWeek == todayName).toList();
          final nextClass = todayClasses.isNotEmpty ? todayClasses.first : null;

          return StreamBuilder<List<PaymentRecord>>(
            stream: FirestoreRefs.payments
                .where('studentId', isEqualTo: student?.uid ?? '')
                .snapshots()
                .map((snapshot) {
              return snapshot.docs.map((doc) {
                return PaymentRecord.fromMap(doc.data() as Map<String, dynamic>);
              }).toList();
            }),
            builder: (context, paymentSnapshot) {
              final payments = paymentSnapshot.data ?? [];
              final totalExpected =
                  (student?.installmentValue ?? 0) * 12;
              final totalPaid = payments.fold<double>(
                0,
                (sum, p) => sum + p.paidAmount,
              );
              final remaining = totalExpected - totalPaid;
              String paymentStatusText;
              Color paymentStatusColor;
              if (remaining <= 0) {
                paymentStatusText = 'مدفوع بالكامل';
                paymentStatusColor = AppColors.success;
              } else if (totalPaid > 0) {
                paymentStatusText =
                    'متبقي ${remaining.toStringAsFixed(0)} ل.س';
                paymentStatusColor = AppColors.warning;
              } else {
                paymentStatusText = 'لم يتم الدفع';
                paymentStatusColor = AppColors.error;
              }

              return StreamBuilder<List<AttendanceRecord>>(
                stream: FirestoreRefs.attendance
                    .where('studentId', isEqualTo: student?.uid ?? '')
                    .snapshots()
                    .map((snapshot) {
                  return snapshot.docs.map((doc) {
                    return AttendanceRecord.fromMap(
                        doc.data() as Map<String, dynamic>);
                  }).toList();
                }),
                builder: (context, attendanceSnapshot) {
                  final attendanceRecords = attendanceSnapshot.data ?? [];
                  final totalSessions = attendanceRecords.length;
                  final presentCount = attendanceRecords
                      .where(
                          (r) => r.status == AttendanceStatus.present)
                      .length;
                  final attendanceRate = totalSessions > 0
                      ? ((presentCount / totalSessions) * 100)
                          .toStringAsFixed(0)
                      : '0';

                  return Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.schedule,
                          value: nextClass != null
                              ? nextClass.startTime
                              : 'لا توجد',
                          title: 'الحصة القادمة',
                          iconColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icon: Icons.payment,
                          value: paymentStatusText,
                          title: 'حالة الأقساط',
                          iconColor: paymentStatusColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icon: Icons.pie_chart,
                          value: '$attendanceRate%',
                          title: 'نسبة الحضور',
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
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final quickActions = [
      _QuickAction(
        icon: Icons.menu_book_rounded,
        title: 'المواد والمدرسين',
        color: AppColors.primary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubjectsScreen()),
          );
        },
      ),
      _QuickAction(
        icon: Icons.schedule_rounded,
        title: 'البرنامج الدراسي',
        color: AppColors.info,
        onTap: () => setState(() => _currentIndex = 3),
      ),
      _QuickAction(
        icon: Icons.check_circle_outline,
        title: 'الحضور والغياب',
        color: AppColors.success,
        onTap: () => setState(() => _currentIndex = 2),
      ),
      _QuickAction(
        icon: Icons.payment_rounded,
        title: 'الأقساط',
        color: AppColors.warning,
        onTap: () => setState(() => _currentIndex = 1),
      ),
      _QuickAction(
        icon: Icons.assignment_rounded,
        title: 'الواجبات',
        color: const Color(0xFF8E44AD),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AssignmentsScreen()),
          );
        },
      ),
      _QuickAction(
        icon: Icons.campaign_rounded,
        title: 'الإعلانات',
        color: AppColors.error,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AnnouncementsScreen()),
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemCount: quickActions.length,
        itemBuilder: (context, index) {
          final action = quickActions[index];
          return QuickActionCard(
            icon: action.icon,
            title: action.title,
            iconColor: action.color,
            onTap: action.onTap,
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(dynamic user, StudentModel? student) {
    return InfoCard(
      title: 'الملف الشخصي',
      value: user.displayName ?? 'طالب',
      subtitle: student != null
          ? '${student.classLevel} - ${student.studentNumber}'
          : user.email,
      icon: Icons.person_rounded,
      color: AppColors.primary,
      onTap: () => setState(() => _currentIndex = 4),
    );
  }

  Widget _buildLatestAnnouncements() {
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
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                'خطأ في تحميل الإعلانات',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final announcements = snapshot.data ?? [];

        if (announcements.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: EmptyState(
              icon: Icons.campaign_outlined,
              message: 'لا توجد إعلانات حالياً',
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: announcements.map((announcement) {
              String dateText = '';
              if (announcement.createdAt != null) {
                final date = announcement.createdAt!;
                dateText =
                    '${date.day}/${date.month}/${date.year}';
              }
              return AnnouncementCard(
                title: announcement.title,
                body: announcement.body,
                date: dateText.isNotEmpty ? dateText : null,
                onTap: () {},
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab(StudentModel? student) {
    if (student == null) {
      return const EmptyView(message: 'لم يتم العثور على بيانات الطالب');
    }
    return PaymentsScreen(student: student);
  }

  Widget _buildAttendanceTab(StudentModel? student) {
    if (student == null) {
      return const EmptyView(message: 'لم يتم العثور على بيانات الطالب');
    }
    return AttendanceScreen(student: student);
  }

  Widget _buildScheduleTab(StudentModel? student) {
    if (student == null) {
      return const EmptyView(message: 'لم يتم العثور على بيانات الطالب');
    }
    return ScheduleScreen(student: student);
  }

  Widget _buildProfileTab(dynamic user) {
    return ProfileScreen(user: user);
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
}

class _QuickAction {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}

class LoginScreenPlaceholder extends StatelessWidget {
  const LoginScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('يرجى تسجيل الدخول'),
      ),
    );
  }
}
