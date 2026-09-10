import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/routing/role_scaffold.dart';
import 'package:alanwar_institute/core/widgets/common_cards.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/features/admin/students/manage_students_screen.dart';
import 'package:alanwar_institute/features/admin/teachers/manage_teachers_screen.dart';
import 'package:alanwar_institute/features/admin/classes/manage_classes_screen.dart';
import 'package:alanwar_institute/features/admin/subjects/manage_subjects_screen.dart';
import 'package:alanwar_institute/features/admin/schedule/manage_schedule_screen.dart';
import 'package:alanwar_institute/features/admin/payments/manage_payments_screen.dart';
import 'package:alanwar_institute/features/admin/reports/reports_screen.dart';
import 'package:alanwar_institute/features/admin/announcements/manage_announcements_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentAppUserProvider);

    return RoleScaffold(
      title: 'لوحة التحكم - الإدارة',
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
      },
      actions: [
        currentUser.when(
          data: (user) {
            if (user == null) return const SizedBox();
            return IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {},
            );
          },
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ),
      ],
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDashboardTab(),
          _buildStudentsTab(),
          _buildTeachersTab(),
          currentUser.when(
            data: (user) {
              if (user == null) return const UnauthorizedView();
              return _buildProfileTab(user);
            },
            loading: () => const LoadingView(),
            error: (_, __) => const ErrorView(message: 'خطأ في تحميل البيانات'),
          ),
        ],
      ),
      bottomNavItems: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'الطلاب',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'المعلمون',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'الملف الشخصي',
        ),
      ],
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بك في نظام إدارة المعهد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'معهد الأنوار',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'إحصائيات سريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatsGrid(),
          const SizedBox(height: 20),
          const Text(
            'الإدارة السريعة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          QuickActionTile(
            icon: Icons.account_tree,
            title: 'إدارة الشعب والبرامج',
            subtitle: 'شعب البكالوريا وبرامج التاسع',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageClassesScreen()),
            ),
          ),
          QuickActionTile(
            icon: Icons.book,
            title: 'إدارة المواد',
            subtitle: 'إضافة وتعديل المواد الدراسية',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageSubjectsScreen()),
            ),
          ),
          QuickActionTile(
            icon: Icons.schedule,
            title: 'إدارة الجدول',
            subtitle: 'تنظيم جدول الحصص',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageScheduleScreen()),
            ),
          ),
          QuickActionTile(
            icon: Icons.payment,
            title: 'إدارة الدفعات',
            subtitle: 'متابعة الدفعات والاقساط',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManagePaymentsScreen()),
            ),
          ),
          QuickActionTile(
            icon: Icons.assessment,
            title: 'التقارير',
            subtitle: 'عرض تقارير مالية وإدارية',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            ),
          ),
          QuickActionTile(
            icon: Icons.announcement,
            title: 'إدارة الإعلانات',
            subtitle: 'نشر إعلانات للمستخدمين',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageAnnouncementsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreRefs.students.where('isActive', isEqualTo: true).snapshots(),
      builder: (context, studentsSnapshot) {
        final studentCount = studentsSnapshot.data?.docs.length ?? 0;

        return StreamBuilder<QuerySnapshot>(
          stream: FirestoreRefs.teachers.where('isActive', isEqualTo: true).snapshots(),
          builder: (context, teachersSnapshot) {
            final teacherCount = teachersSnapshot.data?.docs.length ?? 0;

            return StreamBuilder<QuerySnapshot>(
              stream: FirestoreRefs.subjects.snapshots(),
              builder: (context, subjectsSnapshot) {
                final subjectCount = subjectsSnapshot.data?.docs.length ?? 0;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirestoreRefs.streams.snapshots(),
                  builder: (context, streamsSnapshot) {
                    final streamCount = streamsSnapshot.data?.docs.length ?? 0;

                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatItem(
                          icon: Icons.people,
                          value: '$studentCount',
                          title: 'الطلاب',
                          color: Colors.blue,
                        ),
                        _buildStatItem(
                          icon: Icons.person_outline,
                          value: '$teacherCount',
                          title: 'المعلمون',
                          color: Colors.green,
                        ),
                        _buildStatItem(
                          icon: Icons.book,
                          value: '$subjectCount',
                          title: 'المواد',
                          color: Colors.orange,
                        ),
                        _buildStatItem(
                          icon: Icons.account_tree,
                          value: '$streamCount',
                          title: 'الشعب',
                          color: Colors.purple,
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

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String title,
    required Color color,
  }) {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return const ManageStudentsScreen();
  }

  Widget _buildTeachersTab() {
    return const ManageTeachersScreen();
  }

  Widget _buildProfileTab(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 60,
              color: AppColors.primary,
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
          StatusBadge(text: 'مدير', color: Colors.purple),
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
}
