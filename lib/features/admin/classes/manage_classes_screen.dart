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
            'إدارة الشعب والبرامج',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<List<StreamModel>>(
          stream: ref.watch(streamsStreamProvider).whenData((data) => Stream.value(data)).value,
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

            final streams = snapshot.data ?? [];

            if (streams.isEmpty) {
              return const EmptyView(
                message: 'لا يوجد شعب أو برامج',
                icon: Icons.account_tree,
              );
            }

            final baccalaureateStreams = streams.where((s) => s.classLevel == 'بكالوريا').toList();
            final ninthStreams = streams.where((s) => s.classLevel == 'تاسع').toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (baccalaureateStreams.isNotEmpty) ...[
                    const Text(
                      'شعب البكالوريا',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...baccalaureateStreams.map((stream) => _buildStreamCard(stream)),
                    const SizedBox(height: 16),
                  ],
                  if (ninthStreams.isNotEmpty) ...[
                    const Text(
                      'برامج الصف التاسع',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...ninthStreams.map((stream) => _buildStreamCard(stream)),
                  ],
                  if (streams.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'لا يوجد شعب أو برامج بعد\nاضغط + لإضافة شعبة جديدة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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

  Widget _buildStreamCard(StreamModel stream) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: stream.classLevel == 'بكالوريا'
              ? Colors.blue.withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
          child: Icon(
            stream.classLevel == 'بكالорيا' ? Icons.school : Icons.child_care,
            color: stream.classLevel == 'بكالوريا' ? Colors.blue : Colors.green,
          ),
        ),
        title: Text(
          stream.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المستوى: ${stream.classLevel}'),
            Text('النوع: ${stream.type}'),
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
              _showAddEditDialog(stream: stream);
            } else if (value == 'delete') {
              _deleteStream(stream);
            }
          },
        ),
      ),
    );
  }

  void _showAddEditDialog({StreamModel? stream}) {
    final nameController = TextEditingController(text: stream?.name ?? '');
    String? selectedClassLevel = stream?.classLevel;
    String? selectedType = stream?.type;

    final List<String> types = stream?.classLevel == 'بكالوريا'
        ? ['علمي', 'أدبي']
        : ['برنامج', 'شعبة'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(stream == null ? 'إضافة شعبة جديدة' : 'تعديل الشعبة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الشعبة/البرنامج',
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
                  DropdownMenuItem(value: 'بكالوريا', child: Text('بكالوريا')),
                  DropdownMenuItem(value: 'تاسع', child: Text('تاسع')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedClassLevel = value;
                    selectedType = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (selectedClassLevel != null)
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'النوع',
                    border: OutlineInputBorder(),
                  ),
                  items: (selectedClassLevel == 'بكالوريا'
                          ? ['علمي', 'أدبي']
                          : ['برنامج', 'شعبة'])
                      .map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedType = value);
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
                    selectedClassLevel == null ||
                    selectedType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى ملء جميع الحقول'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  if (stream == null) {
                    final docRef = FirestoreRefs.streams.doc();
                    await docRef.set({
                      'id': docRef.id,
                      'name': nameController.text.trim(),
                      'classLevel': selectedClassLevel!,
                      'type': selectedType!,
                      'createdAt': DateTime.now(),
                    });
                  } else {
                    await FirestoreRefs.streams.doc(stream.id).update({
                      'name': nameController.text.trim(),
                      'classLevel': selectedClassLevel!,
                      'type': selectedType!,
                    });
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(stream == null ? 'تمت الإضافة بنجاح' : 'تم التحديث بنجاح'),
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

  void _deleteStream(StreamModel stream) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الشعبة "${stream.name}"؟\nهذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirestoreRefs.streams.doc(stream.id).delete();
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
