import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/models/class_subject_schedule_model.dart';
import 'package:alanwar_institute/models/teacher_model.dart';

class ManageScheduleScreen extends ConsumerStatefulWidget {
  const ManageScheduleScreen({super.key});

  @override
  ConsumerState<ManageScheduleScreen> createState() => _ManageScheduleScreenState();
}

class _ManageScheduleScreenState extends ConsumerState<ManageScheduleScreen> {
  String _selectedDay = 'السبت';

  final List<String> _days = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'إدارة الجدول',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  final day = _days[index];
                  final isSelected = day == _selectedDay;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedDay = day);
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ScheduleModel>>(
                stream: FirestoreRefs.schedules
                    .where('dayOfWeek', isEqualTo: _selectedDay)
                    .snapshots()
                    .map((snapshot) {
                  return snapshot.docs.map((doc) {
                    return ScheduleModel.fromMap(doc.data() as Map<String, dynamic>);
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

                  final schedules = snapshot.data ?? [];

                  if (schedules.isEmpty) {
                    return const EmptyView(
                      message: 'لا يوجد حصص في هذا اليوم',
                      icon: Icons.schedule,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      return _buildScheduleCard(schedule);
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

  Widget _buildScheduleCard(ScheduleModel schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(Icons.schedule, color: Colors.blue),
        ),
        title: Text(
          schedule.subjectName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${schedule.startTime} - ${schedule.endTime}\n${schedule.teacherName} | ${schedule.room}',
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
              _showAddEditDialog(schedule: schedule);
            } else if (value == 'delete') {
              _deleteSchedule(schedule);
            }
          },
        ),
      ),
    );
  }

  void _showAddEditDialog({ScheduleModel? schedule}) {
    String selectedDay = schedule?.dayOfWeek ?? _selectedDay;
    String? selectedClassId = schedule?.classId;
    String? selectedSubjectId = schedule?.subjectId;
    String? selectedTeacherId = schedule?.teacherId;
    String subjectName = schedule?.subjectName ?? '';
    String teacherName = schedule?.teacherName ?? '';
    final roomController = TextEditingController(text: schedule?.room ?? '');
    final startTimeController = TextEditingController(text: schedule?.startTime ?? '');
    final endTimeController = TextEditingController(text: schedule?.endTime ?? '');

    final classesAsync = ref.read(classesStreamProvider);
    final subjectsAsync = ref.read(subjectsStreamProvider);
    final teachersAsync = ref.read(teachersStreamProvider);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(schedule == null ? 'إضافة حصة جديدة' : 'تعديل الحصة'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(
                    labelText: 'اليوم',
                    border: OutlineInputBorder(),
                  ),
                  items: _days.map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedDay = value!);
                  },
                ),
                const SizedBox(height: 16),
                classesAsync.when(
                  data: (classes) {
                    return DropdownButtonFormField<String>(
                      value: selectedClassId,
                      decoration: const InputDecoration(
                        labelText: 'الفصل',
                        border: OutlineInputBorder(),
                      ),
                      items: classes.map((cls) {
                        return DropdownMenuItem(
                          value: cls.id,
                          child: Text(cls.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedClassId = value;
                          selectedSubjectId = null;
                          selectedTeacherId = null;
                          subjectName = '';
                          teacherName = '';
                        });
                      },
                    );
                  },
                  loading: () => const LoadingView(),
                  error: (_, __) => const Text('خطأ'),
                ),
                const SizedBox(height: 16),
                subjectsAsync.when(
                  data: (subjects) {
                    final filteredSubjects = selectedClassId != null
                        ? subjects.where((s) => s.classIds.contains(selectedClassId)).toList()
                        : subjects;

                    return DropdownButtonFormField<String>(
                      value: selectedSubjectId,
                      decoration: const InputDecoration(
                        labelText: 'المادة',
                        border: OutlineInputBorder(),
                      ),
                      items: filteredSubjects.map((subject) {
                        return DropdownMenuItem(
                          value: subject.id,
                          child: Text(subject.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedSubjectId = value;
                          final selectedSubject = filteredSubjects.firstWhere(
                            (s) => s.id == value,
                            orElse: () => filteredSubjects.first,
                          );
                          subjectName = selectedSubject.name;
                          if (selectedSubject.teacherId.isNotEmpty) {
                            selectedTeacherId = selectedSubject.teacherId;
                            final teacher = teachersAsync.valueOrNull?.firstWhere(
                              (t) => t.uid == selectedSubject.teacherId,
                              orElse: () => TeacherModel(
                                uid: '',
                                fullName: '',
                                teacherNumber: '',
                                phone: '',
                                email: '',
                              ),
                            );
                            teacherName = teacher?.fullName ?? '';
                          }
                        });
                      },
                    );
                  },
                  loading: () => const LoadingView(),
                  error: (_, __) => const Text('خطأ'),
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
                        setDialogState(() {
                          selectedTeacherId = value;
                          final teacher = activeTeachers.firstWhere(
                            (t) => t.uid == value,
                            orElse: () => TeacherModel(
                              uid: '',
                              fullName: '',
                              teacherNumber: '',
                              phone: '',
                              email: '',
                            ),
                          );
                          teacherName = teacher.fullName;
                        });
                      },
                    );
                  },
                  loading: () => const LoadingView(),
                  error: (_, __) => const Text('خطأ'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(
                    labelText: 'وقت البداية',
                    border: OutlineInputBorder(),
                    hintText: '08:00',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(
                    labelText: 'وقت النهاية',
                    border: OutlineInputBorder(),
                    hintText: '09:00',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: roomController,
                  decoration: const InputDecoration(
                    labelText: 'القاعة',
                    border: OutlineInputBorder(),
                  ),
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
                if (selectedClassId == null ||
                    selectedSubjectId == null ||
                    startTimeController.text.isEmpty ||
                    endTimeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى ملء جميع الحقول المطلوبة'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  if (schedule == null) {
                    final docRef = FirestoreRefs.schedules.doc();
                    await docRef.set({
                      'id': docRef.id,
                      'dayOfWeek': selectedDay,
                      'startTime': startTimeController.text.trim(),
                      'endTime': endTimeController.text.trim(),
                      'subjectId': selectedSubjectId!,
                      'subjectName': subjectName,
                      'teacherId': selectedTeacherId ?? '',
                      'teacherName': teacherName,
                      'classId': selectedClassId!,
                      'room': roomController.text.trim(),
                    });
                  } else {
                    await FirestoreRefs.schedules.doc(schedule.id).update({
                      'dayOfWeek': selectedDay,
                      'startTime': startTimeController.text.trim(),
                      'endTime': endTimeController.text.trim(),
                      'subjectId': selectedSubjectId!,
                      'subjectName': subjectName,
                      'teacherId': selectedTeacherId ?? '',
                      'teacherName': teacherName,
                      'classId': selectedClassId!,
                      'room': roomController.text.trim(),
                    });
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(schedule == null ? 'تمت الإضافة بنجاح' : 'تم التحديث بنجاح'),
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

  void _deleteSchedule(ScheduleModel schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الحصة؟\nهذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirestoreRefs.schedules.doc(schedule.id).delete();
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
