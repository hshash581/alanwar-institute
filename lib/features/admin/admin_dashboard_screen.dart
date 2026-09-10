import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/routing/role_scaffold.dart';
import 'package:alanwar_institute/core/widgets/common_cards.dart';
import 'package:alanwar_institute/core/widgets/dashboard_header.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/features/admin/students/manage_students_screen.dart';
import 'package:alanwar_institute/features/admin/teachers/manage_teachers_screen.dart';
import 'package:alanwar_institute/features/admin/schedule/manage_schedule_screen.dart';
import 'package:alanwar_institute/features/admin/payments/manage_payments_screen.dart';
import 'package:alanwar_institute/features/admin/reports/reports_screen.dart';
import 'package:alanwar_institute/features/admin/announcements/manage_announcements_screen.dart';
import 'package:alanwar_institute/features/admin/classes/manage_classes_screen.dart';
import 'package:alanwar_institute/features/admin/subjects/manage_subjects_screen.dart';
import 'package:alanwar_institute/features/admin/admin_management_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _chartAnimationController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _chartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeInOutCubic,
    );
    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء الخير';
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
        return 'اليوم';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentAppUserProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: currentUser.when(
        data: (user) {
          if (user == null) {
            return const Scaffold(body: LoginScreenPlaceholder());
          }
          return RoleScaffold(
            title: 'لوحة التحكم',
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            body: IndexedStack(
              index: _currentIndex,
              children: [
                _buildDashboardTab(user.displayName),
                const ManageStudentsScreen(),
                const ManageTeachersScreen(),
                const ManageScheduleScreen(),
                _buildMoreTab(user),
              ],
            ),
            bottomNavItems: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                activeIcon: Icon(Icons.school),
                label: 'الطلاب',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'المدرسين',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'البرنامج',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz_outlined),
                activeIcon: Icon(Icons.more_horiz),
                label: 'المزيد',
              ),
            ],
          );
        },
        loading: () => const Scaffold(body: LoadingView()),
        error: (_, __) => const Scaffold(body: ErrorView(message: 'خطأ في تحميل البيانات')),
      ),
    );
  }

  Widget _buildDashboardTab(String userName) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(
            greeting: '${_getGreeting()}،',
            name: userName,
            subtitle: _getTodayName(),
            role: 'مدير المعهد',
            showNotification: true,
            onNotificationTap: () {},
          ),
          const SizedBox(height: 16),
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const SectionHeader(title: 'إحصائيات سريعة'),
          ),
          const SizedBox(height: 12),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const SectionHeader(title: 'إجراءات سريعة'),
          ),
          const SizedBox(height: 12),
          _buildQuickActionsGrid(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const SectionHeader(title: 'إحصائيات المعهد'),
          ),
          const SizedBox(height: 12),
          _buildBarChartSection(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const SectionHeader(title: 'حالة الأقساط'),
          ),
          const SizedBox(height: 12),
          _buildPieChartSection(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(
              title: 'أحدث الإعلانات',
              actionText: 'عرض الكل',
              onActionTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageAnnouncementsScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildLatestAnnouncements(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.lightGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.waving_hand,
                color: AppColors.primaryBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'مرحباً بك في نظام إدارة المعهد',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'تستطيع متابعة وإدارة جميع أنشطة المعهد من هنا',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.subtitleText.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreRefs.students
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, studentsSnapshot) {
          final studentCount = studentsSnapshot.data?.docs.length ?? 0;

          return StreamBuilder<QuerySnapshot>(
            stream: FirestoreRefs.teachers
                .where('isActive', isEqualTo: true)
                .snapshots(),
            builder: (context, teachersSnapshot) {
              final teacherCount = teachersSnapshot.data?.docs.length ?? 0;

              return StreamBuilder<QuerySnapshot>(
                stream: FirestoreRefs.schedules.snapshots(),
                builder: (context, schedulesSnapshot) {
                  final todayName = _getTodayName();
                  final todayScheduleCount = schedulesSnapshot.data?.docs
                      .where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['dayOfWeek'] == todayName;
                      })
                      .length ??
                      0;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirestoreRefs.payments.snapshots(),
                    builder: (context, paymentsSnapshot) {
                      double totalRevenue = 0;
                      if (paymentsSnapshot.data != null) {
                        for (final doc in paymentsSnapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final amount = (data['amount'] ?? 0).toDouble();
                          totalRevenue += amount;
                        }
                      }

                      return GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.6,
                        children: [
                          StatCard(
                            icon: Icons.school,
                            value: '$studentCount',
                            title: 'الطلاب',
                            iconColor: const Color(0xFF2E5BFF),
                            valueColor: const Color(0xFF2E5BFF),
                            onTap: () => setState(() => _currentIndex = 1),
                          ),
                          StatCard(
                            icon: Icons.person_outline,
                            value: '$teacherCount',
                            title: 'المعلمون',
                            iconColor: const Color(0xFF27AE60),
                            valueColor: const Color(0xFF27AE60),
                            onTap: () => setState(() => _currentIndex = 2),
                          ),
                          StatCard(
                            icon: Icons.schedule,
                            value: '$todayScheduleCount',
                            title: 'حصص اليوم',
                            iconColor: const Color(0xFFF39C12),
                            valueColor: const Color(0xFFF39C12),
                            onTap: () => setState(() => _currentIndex = 3),
                          ),
                          StatCard(
                            icon: Icons.account_balance_wallet,
                            value: _formatCurrency(totalRevenue),
                            title: 'الإيرادات',
                            iconColor: const Color(0xFF8E44AD),
                            valueColor: const Color(0xFF8E44AD),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ReportsScreen()),
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
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
        children: [
          QuickActionCard(
            icon: Icons.account_tree,
            title: 'إدارة الشعب',
            iconColor: const Color(0xFF2E5BFF),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageClassesScreen()),
            ),
          ),
          QuickActionCard(
            icon: Icons.book,
            title: 'إدارة المواد',
            iconColor: const Color(0xFFF39C12),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageSubjectsScreen()),
            ),
          ),
          QuickActionCard(
            icon: Icons.schedule,
            title: 'إدارة الجدول',
            iconColor: const Color(0xFF27AE60),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageScheduleScreen()),
            ),
          ),
          QuickActionCard(
            icon: Icons.payment,
            title: 'إدارة الدفعات',
            iconColor: const Color(0xFF8E44AD),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManagePaymentsScreen()),
            ),
          ),
          QuickActionCard(
            icon: Icons.assessment,
            title: 'التقارير',
            iconColor: const Color(0xFFE74C3C),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            ),
          ),
          QuickActionCard(
            icon: Icons.campaign,
            title: 'إدارة الإعلانات',
            iconColor: const Color(0xFF1ABC9C),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ManageAnnouncementsScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreRefs.payments.snapshots(),
        builder: (context, snapshot) {
          final monthlyData = _calculateMonthlyRevenue(snapshot.data?.docs ?? []);
          final maxValue = monthlyData.fold<double>(
            0,
            (max, val) => val > max ? val : max,
          );

          return Container(
            height: 260,
            padding: const EdgeInsets.all(20),
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
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxValue > 0 ? maxValue * 1.2 : 1000,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            _formatCurrency(rod.toY),
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            final months = [
                              'يناير', 'فبراير', 'مارس', 'أبريل',
                              'مايو', 'يونيو', 'يوليو', 'أغسطس',
                              'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
                            ];
                            final index = value.toInt();
                            if (index >= 0 && index < months.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  months[index],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.subtitleText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            if (value >= 1000) {
                              return Text(
                                '${(value / 1000).toStringAsFixed(0)}k',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.subtitleText,
                                ),
                              );
                            }
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.subtitleText,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxValue > 0 ? maxValue / 4 : 250,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(12, (index) {
                      final animatedValue =
                          monthlyData[index] * _chartAnimation.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: animatedValue,
                            width: 14,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryBlue.withOpacity(0.7),
                                AppColors.primaryBlue,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPieChartSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreRefs.payments.snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          int paid = 0;
          int overdue = 0;
          int unpaid = 0;

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status']?.toString() ?? 'unpaid';
            if (status == 'paid' || status == 'مدفوع') {
              paid++;
            } else if (status == 'overdue' || status == 'متأخر') {
              overdue++;
            } else {
              unpaid++;
            }
          }

          final total = paid + overdue + unpaid;

          return Container(
            padding: const EdgeInsets.all(20),
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
            child: total == 0
                ? const SizedBox(
                    height: 180,
                    child: Center(
                      child: Text(
                        'لا توجد بيانات أقساط',
                        style: TextStyle(
                          color: AppColors.subtitleText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: AnimatedBuilder(
                          animation: _chartAnimation,
                          builder: (context, child) {
                            return PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(
                                    value: paid.toDouble() *
                                        _chartAnimation.value,
                                    color: const Color(0xFF27AE60),
                                    title: paid.toString(),
                                    radius: 50,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: overdue.toDouble() *
                                        _chartAnimation.value,
                                    color: const Color(0xFFF39C12),
                                    title: overdue.toString(),
                                    radius: 50,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    value: unpaid.toDouble() *
                                        _chartAnimation.value,
                                    color: const Color(0xFFE74C3C),
                                    title: unpaid.toString(),
                                    radius: 50,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPieLegend(
                            color: const Color(0xFF27AE60),
                            label: 'مدفوع',
                            count: paid,
                            total: total,
                          ),
                          _buildPieLegend(
                            color: const Color(0xFFF39C12),
                            label: 'متأخر',
                            count: overdue,
                            total: total,
                          ),
                          _buildPieLegend(
                            color: const Color(0xFFE74C3C),
                            label: 'غير مدفوع',
                            count: unpaid,
                            total: total,
                          ),
                        ],
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildPieLegend({
    required Color color,
    required String label,
    required int count,
    required int total,
  }) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.darkText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$count ($percentage%)',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.subtitleText.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestAnnouncements() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirestoreRefs.announcements
            .orderBy('createdAt', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return const SizedBox(
              height: 120,
              child: Center(
                child: Text(
                  'خطأ في تحميل الإعلانات',
                  style: TextStyle(color: AppColors.subtitleText),
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const EmptyState(
              icon: Icons.campaign_outlined,
              message: 'لا توجد إعلانات حالياً',
            );
          }

          return Column(
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final title = data['title'] ?? 'إعلان جديد';
              final body = data['body'] ?? '';
              final createdAt = data['createdAt'] as Timestamp?;
              String dateStr = '';
              if (createdAt != null) {
                final date = createdAt.toDate();
                dateStr =
                    '${date.day}/${date.month}/${date.year}';
              }
              return AnnouncementCard(
                title: title,
                body: body,
                date: dateStr,
                onTap: () {},
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildMoreTab(dynamic user) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.person,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.subtitleText,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'مدير المعهد',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'الملف الشخصي',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.admin_panel_settings,
            title: 'إدارة المديرين',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageAdminsScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'إدارة الإشعارات',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'تغيير كلمة المرور',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'حول التطبيق',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'معهد الأنوار',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.school,
                  size: 40,
                  color: AppColors.primary,
                ),
                children: const [
                  Text('نظام إدارة معهد الأنوار التعليمي'),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
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
                  if (confirmed == true && mounted) {
                    ref.read(authServiceProvider).signOut();
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.darkText, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_left,
          color: AppColors.mediumGray,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  List<double> _calculateMonthlyRevenue(List<QueryDocumentSnapshot> docs) {
    final monthlyData = List<double>.filled(12, 0);
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] ?? 0).toDouble();
      final date = data['date'] as Timestamp?;
      if (date != null) {
        final month = date.toDate().month - 1;
        if (month >= 0 && month < 12) {
          monthlyData[month] += amount;
        }
      } else {
        final createdAt = data['createdAt'] as Timestamp?;
        if (createdAt != null) {
          final month = createdAt.toDate().month - 1;
          if (month >= 0 && month < 12) {
            monthlyData[month] += amount;
          }
        }
      }
    }
    return monthlyData;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class LoginScreenPlaceholder extends StatelessWidget {
  const LoginScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'يرجى تسجيل الدخول',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'يرجى تسجيل الدخول للوصول إلى لوحة التحكم',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.subtitleText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
