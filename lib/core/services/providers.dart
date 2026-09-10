import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alanwar_institute/models/user_model.dart';
import 'package:alanwar_institute/models/class_subject_schedule_model.dart';
import 'package:alanwar_institute/models/teacher_model.dart';
import 'package:alanwar_institute/models/student_model.dart';
import 'package:alanwar_institute/core/services/auth_service.dart';
import 'package:alanwar_institute/core/services/admin_repository.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AdminRepository(authService);
});

final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentAppUserProvider = StreamProvider<AppUser?>((ref) {
  final authState = ref.watch(firebaseAuthStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return FirestoreRefs.users.doc(user.uid).snapshots().asyncMap((doc) async {
        if (!doc.exists) {
          final email = user.email ?? '';
          final displayName = user.displayName ?? 'مستخدم جديد';
          String roleStr = 'student';
          if (email.contains('admin') || email.contains('manager')) {
            roleStr = 'admin';
          }
          try {
            await FirestoreRefs.users.doc(user.uid).set({
              'uid': user.uid,
              'email': email,
              'displayName': displayName,
              'username': email.split('@').first,
              'role': roleStr,
              'isActive': true,
              'createdAt': FieldValue.serverTimestamp(),
            });
            return AppUser(
              uid: user.uid,
              email: email,
              displayName: displayName,
              username: email.split('@').first,
              role: UserRole.student,
              isActive: true,
            );
          } catch (e) {
            return null;
          }
        }
        final data = doc.data();
        if (data == null) return null;
        return AppUser.fromMap(data as Map<String, dynamic>);
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

final classesStreamProvider = StreamProvider<List<ClassModel>>((ref) {
  return FirestoreRefs.classes.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return ClassModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  });
});

final subjectsStreamProvider = StreamProvider<List<SubjectModel>>((ref) {
  return FirestoreRefs.subjects.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return SubjectModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  });
});

final teachersStreamProvider = StreamProvider<List<TeacherModel>>((ref) {
  return FirestoreRefs.teachers.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return TeacherModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  });
});

final studentsStreamProvider = StreamProvider<List<StudentModel>>((ref) {
  return FirestoreRefs.students.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      return StudentModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  });
});
