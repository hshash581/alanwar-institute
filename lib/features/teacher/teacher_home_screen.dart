import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_anwar_institute/core/services/providers.dart';
import 'package:al_anwar_institute/core/services/firebase_refs.dart';
import 'package:al_anwar_institute/core/constants/app_colors.dart';
import 'package:al_anwar_institute/core/routing/role_scaffold.dart';
import 'package:al_anwar_institute/core/widgets/state_widgets.dart';
import 'package:al_anwar_institute/core/widgets/common_cards.dart';
import 'package:al_anwar_institute/features/teacher/class_attendance_screen.dart';
import 'package:al_anwar_institute/models/class_subject_schedule_model.dart';
import 'package:al_anwar_institute/models/records_model.dart';

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
        if (user == null) return const LoginScreenPlaceholder();

        return RoleScaffold(
          title: 'مرحباً ${user.displayName}',
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _buildMyClassesTab(user.uid),
              _buildAnnouncementsTab(),
              _buildProfileTab(user),
            ],
          ),
          bottomNavItems: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.class_),
              label: 'فصولي',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.announcement),
              label: 'الإعلانات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'الملف الشخصي',
            ),
          ],
        );
      },
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, __) => const Scaffold(body: ErrorView(message: 'خطأ')),
    );
  }

  Widget _buildMyClassesTab(String teacherId) {
    final today = _getTodayName();

    return StreamBuilder<List<ScheduleModel>>(
      stream: FirestoreRefs.schedules
          .where('teacherId', isEqualTo: teacherId)
          .where('dayOfWeek', isEqualTo: today)
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
            onRetry: () => setState(() {}),
          );
        }

        final schedules = snapshot.data ?? [];

        if (schedules.isEmpty) {
          return const EmptyView(
            message: 'لا توجد حصص اليوم',
            icon: Icons.class_,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.schedule, color: Colors.blue),
                ),
                title: Text(
                  schedule.subjectName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${schedule.startTime} - ${schedule.endTime}\nالقاعة: ${schedule.room}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnnouncementsTab() {
    return StreamBuilder<List<AnnouncementModel>>(
      stream: FirestoreRefs.announcements.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return AnnouncementModel.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }

        if (snapshot.hasError) {
          return ErrorView(
            message: 'خطأ في تحميل البيانات',
            onRetry: () => setState(() {}),
          );
        }

        final announcements = snapshot.data ?? [];

        if (announcements.isEmpty) {
          return const EmptyView(
            message: 'لا توجد إعلانات',
            icon: Icons.announcement,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      announcement.body,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileTab(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const StatusBadge(text: 'معلم', color: Colors.green),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('تأكيد تسجيل الخروج'),
                  content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('إلغاء'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                ref.read(authServiceProvider).signOut();
              }
            },
          ),
        ],
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
