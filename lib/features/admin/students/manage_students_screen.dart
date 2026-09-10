import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/models/student_model.dart';
import 'package:alanwar_institute/features/admin/students/add_edit_student_screen.dart';
import 'package:alanwar_institute/features/admin/students/student_detail_screen.dart';

class ManageStudentsScreen extends ConsumerStatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  ConsumerState<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends ConsumerState<ManageStudentsScreen> {
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
                hintText: 'بحث عن طالب...',
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
            child: StreamBuilder<List<StudentModel>>(
              stream: ref.watch(studentsStreamProvider).whenData((data) => Stream.value(data)).value,
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

                final students = snapshot.data ?? [];
                final filteredStudents = students.where((student) {
                  final query = _searchQuery.toLowerCase();
                  return student.fullName.toLowerCase().contains(query) ||
                      student.studentNumber.toLowerCase().contains(query) ||
                      student.phone.contains(query);
                }).toList();

                if (filteredStudents.isEmpty) {
                  return const EmptyView(
                    message: 'لا يوجد طلاب',
                    icon: Icons.people_outline,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return _buildStudentCard(student);
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
            MaterialPageRoute(builder: (_) => const AddEditStudentScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStudentCard(StudentModel student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            student.studentNumber.substring(student.studentNumber.length - 2),
            style: TextStyle(color: AppColors.primary),
          ),
        ),
        title: Text(
          student.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(student.studentNumber),
        trailing: Switch(
          value: student.isActive,
          onChanged: (value) async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('تأكيد'),
                content: Text(
                  value ? 'هل تريد تنشيط هذا الطالب؟' : 'هل تريد تعطيل هذا الطالب؟',
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
                await FirestoreRefs.students.doc(student.uid).update({
                  'isActive': value,
                });
                await ref.read(adminRepositoryProvider).setAccountActive(
                      uid: student.uid,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDetailScreen(student: student),
            ),
          );
        },
      ),
    );
  }
}
