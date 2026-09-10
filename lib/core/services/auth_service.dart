import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:al_anwar_institute/models/user_model.dart';
import 'package:al_anwar_institute/core/services/firebase_refs.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<AppUser?> signIn(String identifier, String password) async {
    try {
      String email = identifier;
      if (!identifier.contains('@')) {
        final query = await FirestoreRefs.users
            .where('username', isEqualTo: identifier)
            .limit(1)
            .get();
        if (query.docs.isEmpty) {
          throw Exception('اسم المستخدم غير موجود');
        }
        email = (query.docs.first.data() as Map<String, dynamic>)['email'] ?? '';
      }

      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user == null) throw Exception('فشل تسجيل الدخول');

      final userDoc = await FirestoreRefs.users.doc(cred.user!.uid).get();
      if (!userDoc.exists) throw Exception('لم يتم العثور على بيانات المستخدم');

      final data = userDoc.data() as Map<String, dynamic>;
      if (data['isActive'] == false) {
        throw Exception('هذا الحساب معطل، تواصل مع الإدارة');
      }

      return AppUser.fromMap(data);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
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

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-credential':
        return 'بيانات الدخول غير صحيحة';
      case 'too-many-requests':
        return 'تم تجاوز عدد المحاولات، حاول لاحقاً';
      case 'operation-not-allowed':
        return 'هذه العملية غير مسموح بها';
      default:
        return 'خطأ: ${e.message}';
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
