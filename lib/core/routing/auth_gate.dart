import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/models/user_model.dart';
import 'package:alanwar_institute/features/auth/login_screen.dart';
import 'package:alanwar_institute/features/admin/admin_dashboard_screen.dart';
import 'package:alanwar_institute/features/teacher/teacher_home_screen.dart';
import 'package:alanwar_institute/features/student/student_home_screen.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(firebaseAuthStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const LoginScreen();

        final currentUser = ref.watch(currentAppUserProvider);

        return currentUser.when(
          data: (appUser) {
            if (appUser == null) {
              return const _ErrorView(
                title: 'خطأ في تحميل البيانات',
                message: 'لم يتم العثور على بيانات المستخدم',
              );
            }

            if (!appUser.isActive) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.errorBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.block_rounded,
                              size: 64,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'هذا الحساب معطل',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'يرجى مراجعة إدارة المعهد لتفعيل الحساب',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.read(authServiceProvider).signOut();
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('تسجيل الخروج'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            switch (appUser.role) {
              case UserRole.admin:
                return const AdminDashboardScreen();
              case UserRole.teacher:
                return const TeacherHomeScreen();
              case UserRole.student:
                return const StudentHomeScreen();
            }
          },
          loading: () => const _LoadingView(),
          error: (e, _) => _ErrorView(
            title: 'خطأ في الاتصال',
            message: 'تعذر الاتصال بالخادم، يرجى المحاولة مرة أخرى',
            onRetry: () => ref.invalidate(currentAppUserProvider),
          ),
        );
      },
      loading: () => const _LoadingView(),
      error: (e, _) => _ErrorView(
        title: 'خطأ في المصادقة',
        message: 'تعذر الاتصال بالخادم، يرجى المحاولة مرة أخرى',
        onRetry: () => ref.invalidate(firebaseAuthStateProvider),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryBlue),
              SizedBox(height: 16),
              Text(
                'جاري التحميل...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _ErrorView({
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.warningBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 64,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
