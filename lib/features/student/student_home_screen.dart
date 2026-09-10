import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/routing/role_scaffold.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/core/widgets/common_cards.dart';
import 'package:alanwar_institute/features/student/schedule_screen.dart';
import 'package:alanwar_institute/features/student/attendance_screen.dart';
import 'package:alanwar_institute/features/student/payments_screen.dart';
import 'package:alanwar_institute/features/student/subjects_screen.dart';
import 'package:alanwar_institute/features/student/assignments_screen.dart';
import 'package:alanwar_institute/features/student/announcements_screen.dart';
import 'package:alanwar_institute/features/student/profile_screen.dart';
import 'package:alanwar_institute/models/student_model.dart';

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

        return StreamBuilder<List<StudentModel>>(
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

            return RoleScaffold(
              title: 'مرحباً ${user.displayName}',
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              body: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildHomeTab(user, student),
                  _buildScheduleTab(student),
                  _buildAttendanceTab(student),
                  _buildPaymentsTab(student),
                  _buildProfileTab(user),
                ],
              ),
              bottomNavItems: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.schedule),
                  label: 'الجدول',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle),
                  label: 'الحضور',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.payment),
                  label: 'الدفعات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'الملف الشخصي',
                ),
              ],
            );
          },
        );
      },
      loading: () => const Scaffold(body: LoadingView()),
      error: (_, __) => const Scaffold(body: ErrorView(message: 'خطأ')),
    );
  }

  Widget _buildHomeTab(user, StudentModel? student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً ${user.displayName}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'نأمل أن تكون بخير',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          if (student != null) ...[
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.school,
                    value: student.classLevel,
                    title: 'المستوى',
                    iconColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icon: Icons.calendar_today,
                    value: student.semester,
                    title: 'الفصل',
                    iconColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'إجراءات سريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          QuickActionTile(
            icon: Icons.schedule,
            title: 'الجدول الدراسي',
            subtitle: 'عرض جدول الحصص',
            onTap: () => setState(() => _currentIndex = 1),
          ),
          QuickActionTile(
            icon: Icons.book,
            title: 'المواد الدراسية',
            subtitle: 'عرض المواد والمعلمين',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubjectsScreen()),
              );
            },
          ),
          QuickActionTile(
            icon: Icons.assignment,
            title: 'الواجبات',
            subtitle: 'عرض الواجبات المطلوبة',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AssignmentsScreen()),
              );
            },
          ),
          QuickActionTile(
            icon: Icons.announcement,
            title: 'الإعلانات',
            subtitle: 'عرض آخر الإعلانات',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(StudentModel? student) {
    if (student == null) return const EmptyView(message: 'لم يتم العثور على بيانات الطالب');
    return ScheduleScreen(student: student);
  }

  Widget _buildAttendanceTab(StudentModel? student) {
    if (student == null) return const EmptyView(message: 'لم يتم العثور على بيانات الطالب');
    return AttendanceScreen(student: student);
  }

  Widget _buildPaymentsTab(StudentModel? student) {
    if (student == null) return const EmptyView(message: 'لم يتم العثور على بيانات الطالب');
    return PaymentsScreen(student: student);
  }

  Widget _buildProfileTab(user) {
    return ProfileScreen(user: user);
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
