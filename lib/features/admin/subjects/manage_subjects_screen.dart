import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/models/class_subject_schedule_model.dart';
import 'package:alanwar_institute/models/teacher_model.dart';

class ManageSubjectsScreen extends ConsumerStatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  ConsumerState<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends ConsumerState<ManageSubjectsScreen> {
  String? _filterClassLevel;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'إدارة المواد',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: FilterChip(
                      label: const Text('الكل'),
                      selected: _filterClassLevel == null,
                      onSelected: (selected) {
                        setState(() => _filterClassLevel = null);
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilterChip(
                      label: const Text('تاسع'),
                      selected: _filterClassLevel == 'تاسع',
                      onSelected: (selected) {
                        setState(() => _filterClassLevel = selected ? 'تاسع' : null);
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilterChip(
                      label: const Text('بكالوريا'),
                      selected: _filterClassLevel == 'بكالوريا',
                      onSelected: (selected) {
                        setState(() => _filterClassLevel = selected ? 'بكالوريا' : null);
                      },
                      selectedColor: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<SubjectModel>>(
                stream: ref.watch(subjectsStreamProvider).whenData((data) => Stream.value(data)).value,
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

                  var subjects = snapshot.data ?? [];

                  if (_filterClassLevel != null) {
                    subjects = subjects.where((s) => s.classLevel == _filterClassLevel).toList();
                  }

                  if (subjects.isEmpty) {
                    return const EmptyView(
                      message: 'لا يوجد مواد',
                      icon: Icons.book,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: subjects.length,
                    itemBuilder: (context, index) {
                      final subject = subjects[index];
                      return _buildSubjectCard(subject);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddEditDialog(),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(SubjectModel subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.1),
          child: const Icon(Icons.book, color: Colors.orange),
        ),
        title: Text(
          subject.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subject.classLevel.isNotEmpty ? 'المستوى: ${subject.classLevel}' : 'بدون مستوى',
              style: TextStyle(
                color: subject.classLevel.isNotEmpty ? Colors.blue : Colors.grey,
                fontSize: 12,
              ),
            ),
            Text(
              subject.teacherId.isNotEmpty ? 'معلم محدد' : 'بدون معلم',
              style: TextStyle(
                color: subject.teacherId.isNotEmpty ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ),
        isThreeLine: true,
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
              _showAddEditDialog(subject: subject);
            } else if (value == 'delete') {
              _deleteSubject(subject);
            }
          },
        ),
      ),
    );
  }

  void _showAddEditDialog({SubjectModel? subject}) {
    final nameController = TextEditingController(text: subject?.name ?? '');
    String? selectedTeacherId = subject?.teacherId;
    String? selectedClassLevel = subject?.classLevel;

    final teachersAsync = ref.read(teachersStreamProvider);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(subject == null ? 'إضافة مادة جديدة' : 'تعديل المادة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المادة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedClassLevel,
                  decoration: const InputDecoration(
                    labelText: 'المستوى الدراسي',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'تاسع', child: Text('تاسع')),
                    DropdownMenuItem(value: 'بكالوريا', child: Text('بكالوريا')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => selectedClassLevel = value);
                  },
                ),
                const SizedBox(height: 16),
                teachersAsync.when(
                  data: (teachers) {
                    final activeTeachers = teachers.where((t) => t.isActive).toList();
                    return DropdownButtonFormField<String>(
                      value: selectedTeacherId,
                      decoration: const InputDecoration(
                        labelText: 'المعلم',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('بدون معلم'),
                        ),
                        ...activeTeachers.map((teacher) {
                          return DropdownMenuItem(
                            value: teacher.uid,
                            child: Text(teacher.fullName),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setDialogState(() => selectedTeacherId = value);
                      },
                    );
                  },
                  loading: () => const LoadingView(),
                  error: (_, __) => const Text('خطأ في تحميل المعلمين'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى إدخال اسم المادة'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  if (subject == null) {
                    final docRef = FirestoreRefs.subjects.doc();
                    await docRef.set({
                      'id': docRef.id,
                      'name': nameController.text.trim(),
                      'teacherId': selectedTeacherId ?? '',
                      'classLevel': selectedClassLevel ?? '',
                    });
                  } else {
                    await FirestoreRefs.subjects.doc(subject.id).update({
                      'name': nameController.text.trim(),
                      'teacherId': selectedTeacherId ?? '',
                      'classLevel': selectedClassLevel ?? '',
                    });
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(subject == null ? 'تمت الإضافة بنجاح' : 'تم التحديث بنجاح'),
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

  void _deleteSubject(SubjectModel subject) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المادة "${subject.name}"؟\nهذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirestoreRefs.subjects.doc(subject.id).delete();
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
