import 'package:flutter/material.dart';
import 'package:al_anwar_institute/core/constants/app_colors.dart';
import 'package:al_anwar_institute/core/services/firebase_refs.dart';
import 'package:al_anwar_institute/core/widgets/state_widgets.dart';
import 'package:al_anwar_institute/models/student_model.dart';
import 'package:al_anwar_institute/models/class_subject_schedule_model.dart';
import 'package:al_anwar_institute/models/teacher_model.dart';

class SubjectsScreen extends StatelessWidget {
  final StudentModel? student;

  const SubjectsScreen({super.key, this.student});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'المواد الدراسية',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
        body: StreamBuilder<List<SubjectModel>>(
          stream: FirestoreRefs.subjects.snapshots().map((snapshot) {
            return snapshot.docs.map((doc) {
              return SubjectModel.fromMap(doc.data() as Map<String, dynamic>);
            }).toList();
          }),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingView();
            }

            if (snapshot.hasError) {
              return ErrorView(
                message: 'خطأ في تحميل البيانات',
                onRetry: () {},
              );
            }

            final subjects = snapshot.data ?? [];

            if (subjects.isEmpty) {
              return const EmptyView(
                message: 'لا توجد مواد',
                icon: Icons.book,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return _buildSubjectCard(subject);
              },
            );
          },
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
        subtitle: subject.teacherId.isNotEmpty
            ? StreamBuilder<List<TeacherModel>>(
                stream: FirestoreRefs.teachers.snapshots().map((snapshot) {
                  return snapshot.docs.map((doc) {
                    return TeacherModel.fromMap(doc.data() as Map<String, dynamic>);
                  }).toList();
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('جاري التحميل...');
                  }
                  final teachers = snapshot.data ?? [];
                  final teacher = teachers.firstWhere(
                    (t) => t.uid == subject.teacherId,
                    orElse: () => TeacherModel(
                      uid: '',
                      fullName: '',
                      teacherNumber: '',
                      phone: '',
                      email: '',
                    ),
                  );
                  return Text(
                    'المعلم: ${teacher.fullName}',
                    style: const TextStyle(color: Colors.grey),
                  );
                },
              )
            : const Text(
                'بدون معلم',
                style: TextStyle(color: Colors.red),
              ),
      ),
    );
  }
}
