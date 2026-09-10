import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/widgets/common_cards.dart';

class ProfileScreen extends ConsumerWidget {
  final dynamic user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
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
            const StatusBadge(text: 'طالب', color: Colors.blue),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person, color: AppColors.primary),
                    title: const Text('الاسم'),
                    subtitle: Text(user.displayName),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.email, color: AppColors.primary),
                    title: const Text('البريد الإلكتروني'),
                    subtitle: Text(user.email),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.badge, color: AppColors.primary),
                    title: const Text('اسم المستخدم'),
                    subtitle: Text(user.username),
                  ),
                ],
              ),
            ),
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
      ),
    );
  }
}
