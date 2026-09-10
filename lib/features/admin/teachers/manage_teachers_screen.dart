import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/core/widgets/common_cards.dart';
import 'package:alanwar_institute/models/teacher_model.dart';
import 'package:alanwar_institute/features/admin/teachers/add_edit_teacher_screen.dart';

class ManageTeachersScreen extends ConsumerStatefulWidget {
  const ManageTeachersScreen({super.key});

  @override
  ConsumerState<ManageTeachersScreen> createState() => _ManageTeachersScreenState();
}

class _ManageTeachersScreenState extends ConsumerState<ManageTeachersScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث عن معلم...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<TeacherModel>>(
              stream: ref.watch(teachersStreamProvider).whenData((data) => Stream.value(data)).value,
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

                final teachers = snapshot.data ?? [];
                final filteredTeachers = teachers.where((teacher) {
                  final query = _searchQuery.toLowerCase();
                  return teacher.fullName.toLowerCase().contains(query) ||
                      teacher.teacherNumber.toLowerCase().contains(query) ||
                      teacher.phone.contains(query);
                }).toList();

                if (filteredTeachers.isEmpty) {
                  return const EmptyView(
                    message: 'لا يوجد معلمون',
                    icon: Icons.person_outline,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTeachers.length,
                  itemBuilder: (context, index) {
                    final teacher = filteredTeachers[index];
                    return _buildTeacherCard(teacher);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTeacherScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTeacherCard(TeacherModel teacher) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: Text(
            teacher.teacherNumber.substring(teacher.teacherNumber.length - 2),
            style: const TextStyle(color: Colors.green),
          ),
        ),
        title: Text(
          teacher.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(teacher.teacherNumber),
        trailing: Switch(
          value: teacher.isActive,
          onChanged: (value) async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('تأكيد'),
                content: Text(
                  value ? 'هل تريد تنشيط هذا المعلم؟' : 'هل تريد تعطيل هذا المعلم؟',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('إلغاء'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      value ? 'تنشيط' : 'تعطيل',
                      style: TextStyle(
                        color: value ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              try {
                await FirestoreRefs.teachers.doc(teacher.uid).update({
                  'isActive': value,
                });
                await ref.read(adminRepositoryProvider).setAccountActive(
                      uid: teacher.uid,
                      isActive: value,
                    );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          },
          activeColor: Colors.green,
        ),
        onTap: () {
          _showTeacherDetail(teacher);
        },
      ),
    );
  }

  void _showTeacherDetail(TeacherModel teacher) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green.withOpacity(0.1),
                child: Text(
                  teacher.teacherNumber.substring(teacher.teacherNumber.length - 2),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                teacher.fullName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: StatusBadge(
                text: teacher.isActive ? 'نشط' : 'معطل',
                color: teacher.isActive ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('رقم المعلم', teacher.teacherNumber),
            _buildInfoRow('رقم الهاتف', teacher.phone),
            _buildInfoRow('البريد الإلكتروني', teacher.email),
            if (teacher.notes.isNotEmpty)
              _buildInfoRow('ملاحظات', teacher.notes),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditTeacherScreen(teacher: teacher),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      'تعديل',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      'إغلاق',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'غير محدد',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
