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
          const Text(
            'مرحباً بك في نظام إدارة المعهد',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirestoreRefs.students.where('isActive', isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return StatCard(
                icon: Icons.people,
                value: '$count',
                title: 'الطلاب النشطين',
                iconColor: Colors.blue,
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirestoreRefs.teachers.where('isActive', isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return StatCard(
                icon: Icons.person_outline,
                value: '$count',
                title: 'المعلمون النشطون',
                iconColor: Colors.green,
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'الإدارة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          QuickActionTile(
            icon: Icons.school,
            title: 'إدارة الفصول',
            subtitle: 'إضافة وتعديل الفصول الدراسية',
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
