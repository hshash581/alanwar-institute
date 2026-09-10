import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:alanwar_institute/models/user_model.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AppUser?> signIn(String identifier, String password) async {
    String email = identifier;

    if (!identifier.contains('@')) {
      final query = await FirestoreRefs.usernames
          .doc(identifier.toLowerCase())
          .get();
      if (!query.exists) {
        throw Exception('لم يتم العثور على حساب بهذا الاسم');
      }
      final data = query.data() as Map<String, dynamic>;
      email = data['email'] ?? '';
      if (email.isEmpty) {
        throw Exception('بيانات الحساب غير مكتملة');
      }
    }

    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (cred.user == null) throw Exception('فشل تسجيل الدخول');

    final userDoc = await FirestoreRefs.users.doc(cred.user!.uid).get();
    if (!userDoc.exists) {
      throw Exception('لم يتم العثور على بيانات المستخدم في النظام');
    }

    final userData = userDoc.data() as Map<String, dynamic>;
    if (userData['isActive'] == false) {
      throw Exception('هذا الحساب معطل، يرجى مراجعة إدارة المعهد');
    }

    return AppUser.fromMap(userData);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AppUser?> fetchAppUser(String uid) async {
    try {
      final doc = await FirestoreRefs.users.doc(uid).get();
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<GeneratedCredentials> createUserByAdmin({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? username,
    required String createdBy,
  }) async {
    try {
      final secondaryApp = await Firebase.initializeApp(
        name: 'admin-secondary-${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await cred.user!.updateDisplayName(displayName);

      final appUser = AppUser(
        uid: cred.user!.uid,
        displayName: displayName,
        email: email,
        username: username ?? email.split('@').first,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
        createdBy: createdBy,
      );

      await FirestoreRefs.users.doc(cred.user!.uid).set(appUser.toMap());

      final resolvedUsername = username ?? email.split('@').first;
      await FirestoreRefs.usernames.doc(resolvedUsername.toLowerCase()).set({
        'email': email,
        'uid': cred.user!.uid,
        'username': resolvedUsername,
      });

      await secondaryApp.delete();

      return GeneratedCredentials(
        uid: cred.user!.uid,
        email: email,
        password: password,
        displayName: displayName,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  String generatePassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    String password = '';
    for (int i = 0; i < 12; i++) {
      password += chars[(random + i * 7) % chars.length];
    }
    return password;
  }

  Future<void> resetPasswordForAdmin({
    required String uid,
    required String newPassword,
  }) async {
    try {
      final userDoc = await FirestoreRefs.users.doc(uid).get();
      if (!userDoc.exists) throw Exception('المستخدم غير موجود');

      final data = userDoc.data() as Map<String, dynamic>;
      final email = data['email'] ?? '';

      final secondaryApp = await Firebase.initializeApp(
        name: 'reset-${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      await secondaryAuth.sendPasswordResetEmail(email: email);

      await secondaryApp.delete();
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  String mapFirebaseError(dynamic e) {
    if (e is FirebaseAuthException) return _mapFirebaseError(e);
    final msg = e.toString();
    if (msg.contains('unavailable') || msg.contains('UNAVAILABLE')) {
      return 'الخادم غير متاح حالياً، يرجى المحاولة مرة أخرى';
    }
    if (msg.contains('network') || msg.contains('Network')) {
      return 'تعذر الاتصال بالإنترنت، تحقق من اتصالك وحاول مرة أخرى';
    }
    return 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لم يتم العثور على هذا الحساب';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'invalid-credential':
        return 'اسم المستخدم أو كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات، يرجى الانتظار والمحاولة لاحقاً';
      case 'operation-not-allowed':
        return 'هذه العملية غير مسموح بها';
      case 'user-disabled':
        return 'هذا الحساب معطل، يرجى مراجعة إدارة المعهد';
      case 'network-request-failed':
        return 'تعذر الاتصال بالإنترنت';
      default:
        return 'خطأ في تسجيل الدخول: ${e.message}';
    }
  }
}

class GeneratedCredentials {
  final String uid;
  final String email;
  final String password;
  final String displayName;

  GeneratedCredentials({
    required this.uid,
    required this.email,
    required this.password,
    required this.displayName,
  });
}
