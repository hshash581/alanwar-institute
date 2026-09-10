import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_anwar_institute/core/services/providers.dart';
import 'package:al_anwar_institute/features/auth/login_screen.dart';
import 'package:al_anwar_institute/features/admin/admin_dashboard_screen.dart';
import 'package:al_anwar_institute/features/teacher/teacher_home_screen.dart';
import 'package:al_anwar_institute/features/student/student_home_screen.dart';
import 'package:al_anwar_institute/core/widgets/state_widgets.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(firebaseAuthStateProvider);
    final currentUser = ref.watch(currentAppUserProvider);

    return authState.when(
      data: (user) {
        if (user == null) return const LoginScreen();

        return currentUser.when(
          data: (appUser) {
            if (appUser == null) return const LoginScreen();

            if (!appUser.isActive) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'هذا الحساب معطل',
                    style: TextStyle(fontSize: 18),
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
          loading: () => const LoadingView(),
          error: (e, _) => Scaffold(
            body: Center(child: Text('خطأ: $e')),
          ),
        );
      },
      loading: () => const LoadingView(),
      error: (e, _) => Scaffold(
        body: Center(child: Text('خطأ: $e')),
      ),
    );
  }
}
