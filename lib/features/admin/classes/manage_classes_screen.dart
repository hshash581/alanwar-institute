import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/models/class_subject_schedule_model.dart';

class ManageClassesScreen extends ConsumerStatefulWidget {
  const ManageClassesScreen({super.key});

  @override
  ConsumerState<ManageClassesScreen> createState() => _ManageClassesScreenState();
}

class _ManageClassesScreenState extends ConsumerState<ManageClassesScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'إدارة الفصول',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<List<ClassModel>>(
          stream: ref.watch(classesStreamProvider).whenData((data) => Stream.value(data)).value,
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

            final classes = snapshot.data ?? [];

            if (classes.isEmpty) {
              return const EmptyView(
                message: 'لا يوجد فصول',
                icon: Icons.class_,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final cls = classes[index];
                return _buildClassCard(cls);
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddEditDialog(),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildClassCard(ClassModel cls) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(Icons.class_, color: AppColors.primary),
        ),
        title: Text(
          cls.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${cls.grade} - ${cls.branch}'),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('تعديل'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'حذف',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showAddEditDialog(cls: cls);
            } else if (value == 'delete') {
              _deleteClass(cls);
            }
          },
        ),
      ),
    );
  }

  void _showAddEditDialog({ClassModel? cls}) {
    final nameController = TextEditingController(text: cls?.name ?? '');
    String? selectedGrade = cls?.grade;
    String? selectedBranch = cls?.branch;

    final grades = ['الأولى', 'الثانية', 'الثالثة', 'الرابعة', 'الخامسة', 'السادسة'];
    final branches = ['الفرع الرئيسي', 'الفرع الثاني'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(cls == null ? 'إضافة فصل جديد' : 'تعديل الفصل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الفصل',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGrade,
                decoration: const InputDecoration(
                  labelText: 'المستوى الدراسي',
                  border: OutlineInputBorder(),
                ),
                items: grades.map((grade) {
                  return DropdownMenuItem(
                    value: grade,
                    child: Text(grade),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedGrade = value);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedBranch,
                decoration: const InputDecoration(
                  labelText: 'الفرع',
                  border: OutlineInputBorder(),
                ),
                items: branches.map((branch) {
                  return DropdownMenuItem(
                    value: branch,
                    child: Text(branch),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedBranch = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    selectedGrade == null ||
                    selectedBranch == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى ملء جميع الحقول'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  if (cls == null) {
                    final docRef = FirestoreRefs.classes.doc();
                    await docRef.set({
                      'id': docRef.id,
                      'name': nameController.text.trim(),
                      'grade': selectedGrade!,
                      'branch': selectedBranch!,
                      'createdAt': DateTime.now(),
                    });
                  } else {
                    await FirestoreRefs.classes.doc(cls.id).update({
                      'name': nameController.text.trim(),
                      'grade': selectedGrade!,
                      'branch': selectedBranch!,
                    });
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(cls == null ? 'تمت الإضافة بنجاح' : 'تم التحديث بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteClass(ClassModel cls) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الفصل "${cls.name}"؟\nهذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirestoreRefs.classes.doc(cls.id).delete();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم الحذف بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
