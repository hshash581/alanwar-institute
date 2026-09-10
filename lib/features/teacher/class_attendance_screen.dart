import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/models/student_model.dart';
import 'package:alanwar_institute/models/records_model.dart';

class ClassAttendanceScreen extends ConsumerStatefulWidget {
  final String classId;
  final String subjectId;
  final String scheduleId;

  const ClassAttendanceScreen({
    super.key,
    required this.classId,
    required this.subjectId,
    required this.scheduleId,
  });

  @override
  ConsumerState<ClassAttendanceScreen> createState() => _ClassAttendanceScreenState();
}

class _ClassAttendanceScreenState extends ConsumerState<ClassAttendanceScreen> {
  final Map<String, AttendanceStatus> _attendanceMap = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تسجيل الحضور',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: StreamBuilder<List<StudentModel>>(
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

            final students = (snapshot.data ?? [])
                .where((s) => s.streamId == widget.classId && s.isActive)
                .toList();

            if (students.isEmpty) {
              return const EmptyView(
                message: 'لا يوجد طلاب في هذا الفصل',
                icon: Icons.people_outline,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return _buildStudentAttendanceCard(student);
              },
            );
          },
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'حفظ الحضور',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentAttendanceCard(StudentModel student) {
    final currentStatus = _attendanceMap[student.uid] ?? AttendanceStatus.absent;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                student.studentNumber.substring(student.studentNumber.length - 2),
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    student.studentNumber,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _buildAttendanceChip(
                  student.uid,
                  AttendanceStatus.present,
                  'حاضر',
                  Colors.green,
                  currentStatus,
                ),
                const SizedBox(width: 4),
                _buildAttendanceChip(
                  student.uid,
                  AttendanceStatus.late,
                  'متأخر',
                  Colors.orange,
                  currentStatus,
                ),
                const SizedBox(width: 4),
                _buildAttendanceChip(
                  student.uid,
                  AttendanceStatus.absent,
                  'غائب',
                  Colors.red,
                  currentStatus,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceChip(
    String studentId,
    AttendanceStatus status,
    String label,
    Color color,
    AttendanceStatus currentStatus,
  ) {
    final isSelected = currentStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _attendanceMap[studentId] = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _saveAttendance() async {
    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(currentAppUserProvider).value;
      final batch = FirestoreRefs.attendance.firestore.batch();

      for (final entry in _attendanceMap.entries) {
        final docRef = FirestoreRefs.attendance.doc();
        batch.set(docRef, {
          'id': docRef.id,
          'studentId': entry.key,
          'classId': widget.classId,
          'subjectId': widget.subjectId,
          'scheduleId': widget.scheduleId,
          'date': DateTime.now(),
          'status': entry.value.name,
          'note': '',
          'recordedBy': currentUser?.uid ?? '',
        });
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الحضور بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
