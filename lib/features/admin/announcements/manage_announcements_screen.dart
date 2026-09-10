import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/models/records_model.dart';
import 'package:alanwar_institute/models/class_subject_schedule_model.dart';

class ManageAnnouncementsScreen extends ConsumerStatefulWidget {
  const ManageAnnouncementsScreen({super.key});

  @override
  ConsumerState<ManageAnnouncementsScreen> createState() => _ManageAnnouncementsScreenState();
}

class _ManageAnnouncementsScreenState extends ConsumerState<ManageAnnouncementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'إدارة الإعلانات',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<List<AnnouncementModel>>(
          stream: FirestoreRefs.announcements.snapshots().map((snapshot) {
            return snapshot.docs.map((doc) {
              return AnnouncementModel.fromMap(doc.data() as Map<String, dynamic>);
            }).toList();
          }),
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

            final announcements = snapshot.data ?? [];

            if (announcements.isEmpty) {
              return const EmptyView(
                message: 'لا توجد إعلانات',
                icon: Icons.announcement,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return _buildAnnouncementCard(announcement);
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

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton(
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
                      _showAddEditDialog(announcement: announcement);
                    } else if (value == 'delete') {
                      _deleteAnnouncement(announcement);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              announcement.body,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.public,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _getTargetText(announcement.target),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog({AnnouncementModel? announcement}) {
    final titleController = TextEditingController(text: announcement?.title ?? '');
    final bodyController = TextEditingController(text: announcement?.body ?? '');
    AnnouncementTarget selectedTarget = announcement?.target ?? AnnouncementTarget.all;
    String? selectedTargetValue = announcement?.targetValue;

    final classesAsync = ref.read(classesStreamProvider);
    final subjectsAsync = ref.read(subjectsStreamProvider);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(announcement == null ? 'إضافة إعلان جديد' : 'تعديل الإعلان'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bodyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'المحتوى',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AnnouncementTarget>(
                  value: selectedTarget,
                  decoration: const InputDecoration(
                    labelText: 'الجمهور المستهدف',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AnnouncementTarget.all,
                      child: Text('الجميع'),
                    ),
                    DropdownMenuItem(
                      value: AnnouncementTarget.classId,
                      child: Text('فصل محدد'),
                    ),
                    DropdownMenuItem(
                      value: AnnouncementTarget.subject,
                      child: Text('مادة محددة'),
                    ),
                    DropdownMenuItem(
                      value: AnnouncementTarget.teachers,
                      child: Text('المعلمون فقط'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedTarget = value!;
                      selectedTargetValue = null;
                    });
                  },
                ),
                if (selectedTarget == AnnouncementTarget.classId) ...[
                  const SizedBox(height: 16),
                  classesAsync.when(
                    data: (classes) {
                      return DropdownButtonFormField<String>(
                        value: selectedTargetValue,
                        decoration: const InputDecoration(
                          labelText: 'اختر الفصل',
                          border: OutlineInputBorder(),
                        ),
                        items: classes.map((cls) {
                          return DropdownMenuItem(
                            value: cls.id,
                            child: Text(cls.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() => selectedTargetValue = value);
                        },
                      );
                    },
                    loading: () => const LoadingView(),
                    error: (_, __) => const Text('خطأ'),
                  ),
                ],
                if (selectedTarget == AnnouncementTarget.subject) ...[
                  const SizedBox(height: 16),
                  subjectsAsync.when(
                    data: (subjects) {
                      return DropdownButtonFormField<String>(
                        value: selectedTargetValue,
                        decoration: const InputDecoration(
                          labelText: 'اختر المادة',
                          border: OutlineInputBorder(),
                        ),
                        items: subjects.map((subject) {
                          return DropdownMenuItem(
                            value: subject.id,
                            child: Text(subject.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() => selectedTargetValue = value);
                        },
                      );
                    },
                    loading: () => const LoadingView(),
                    error: (_, __) => const Text('خطأ'),
                  ),
                ],
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
                if (titleController.text.isEmpty || bodyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى ملء جميع الحقول'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final currentUser = ref.read(currentAppUserProvider).value;

                  if (announcement == null) {
                    final docRef = FirestoreRefs.announcements.doc();
                    await docRef.set({
                      'id': docRef.id,
                      'title': titleController.text.trim(),
                      'body': bodyController.text.trim(),
                      'target': selectedTarget.name,
                      'targetValue': selectedTargetValue,
                      'createdBy': currentUser?.uid ?? '',
                      'createdAt': DateTime.now(),
                    });
                  } else {
                    await FirestoreRefs.announcements.doc(announcement.id).update({
                      'title': titleController.text.trim(),
                      'body': bodyController.text.trim(),
                      'target': selectedTarget.name,
                      'targetValue': selectedTargetValue,
                    });
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(announcement == null ? 'تمت الإضافة بنجاح' : 'تم التحديث بنجاح'),
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

  void _deleteAnnouncement(AnnouncementModel announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الإعلان؟\nهذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirestoreRefs.announcements.doc(announcement.id).delete();
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

  String _getTargetText(AnnouncementTarget target) {
    switch (target) {
      case AnnouncementTarget.all:
        return 'الجميع';
      case AnnouncementTarget.classId:
        return 'فصل محدد';
      case AnnouncementTarget.subject:
        return 'مادة محددة';
      case AnnouncementTarget.teachers:
        return 'المعلمون فقط';
    }
  }
}
