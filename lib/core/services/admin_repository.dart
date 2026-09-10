import 'package:alanwar_institute/models/user_model.dart';
import 'package:alanwar_institute/models/student_model.dart';
import 'package:alanwar_institute/models/teacher_model.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/services/auth_service.dart';

class AdminRepository {
  final AuthService _authService;

  AdminRepository(this._authService);

  Future<GeneratedCredentials> createStudent({
    required String fullName,
    required String phone,
    required String email,
    required String grade,
    required String classId,
    required String branch,
    String? birthDate,
    String address = '',
    String guardianName = '',
    String guardianPhone = '',
    List<String> subjectIds = const [],
    double installmentValue = 0,
    String notes = '',
    required String createdBy,
  }) async {
    try {
      final studentNumber = await FirestoreRefs.nextSequence('STU');
      final username = studentNumber.toLowerCase();
      final password = _authService.generatePassword();

      final credentials = await _authService.createUserByAdmin(
        email: email,
        password: password,
        displayName: fullName,
        role: UserRole.student,
        username: username,
        createdBy: createdBy,
      );

      final student = StudentModel(
        uid: credentials.uid,
        fullName: fullName,
        studentNumber: studentNumber,
        phone: phone,
        email: email,
        grade: grade,
        classId: classId,
        branch: branch,
        birthDate: birthDate != null ? DateTime.tryParse(birthDate) : null,
        address: address,
        guardianName: guardianName,
        guardianPhone: guardianPhone,
        subjectIds: subjectIds,
        installmentValue: installmentValue,
        notes: notes,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await FirestoreRefs.students.doc(credentials.uid).set(student.toMap());

      return GeneratedCredentials(
        uid: credentials.uid,
        email: email,
        password: password,
        displayName: '$studentNumber - $fullName',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<GeneratedCredentials> createTeacher({
    required String fullName,
    required String phone,
    required String email,
    String notes = '',
    required String createdBy,
  }) async {
    try {
      final teacherNumber = await FirestoreRefs.nextSequence('TCH');
      final username = teacherNumber.toLowerCase();
      final password = _authService.generatePassword();

      final credentials = await _authService.createUserByAdmin(
        email: email,
        password: password,
        displayName: fullName,
        role: UserRole.teacher,
        username: username,
        createdBy: createdBy,
      );

      final teacher = TeacherModel(
        uid: credentials.uid,
        fullName: fullName,
        teacherNumber: teacherNumber,
        phone: phone,
        email: email,
        notes: notes,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await FirestoreRefs.teachers.doc(credentials.uid).set(teacher.toMap());

      return GeneratedCredentials(
        uid: credentials.uid,
        email: email,
        password: password,
        displayName: '$teacherNumber - $fullName',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setAccountActive({
    required String uid,
    required bool isActive,
  }) async {
    try {
      await FirestoreRefs.users.doc(uid).update({'isActive': isActive});
    } catch (e) {
      rethrow;
    }
  }

  Future<GeneratedCredentials> createAdmin({
    required String fullName,
    required String email,
    required String createdBy,
  }) async {
    try {
      final password = _authService.generatePassword();
      final username = email.split('@').first;

      final credentials = await _authService.createUserByAdmin(
        email: email,
        password: password,
        displayName: fullName,
        role: UserRole.admin,
        username: username,
        createdBy: createdBy,
      );

      return GeneratedCredentials(
        uid: credentials.uid,
        email: email,
        password: password,
        displayName: fullName,
      );
    } catch (e) {
      rethrow;
    }
  }
}
