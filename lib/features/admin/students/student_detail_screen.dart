import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_anwar_institute/core/services/providers.dart';
import 'package:al_anwar_institute/core/services/firebase_refs.dart';
import 'package:al_anwar_institute/core/constants/app_colors.dart';
import 'package:al_anwar_institute/models/student_model.dart';
import 'package:al_anwar_institute/core/widgets/common_cards.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  final StudentModel student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  ConsumerState<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> {
  late StudentModel _student;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _student.fullName,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                // Navigate to edit screen
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    _student.studentNumber.substring(_student.studentNumber.length - 2),
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _student.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: StatusBadge(
                  text: _student.isActive ? 'نشط' : 'معطل',
                  color: _student.isActive ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoCard('رقم الطالب', _student.studentNumber),
              _buildInfoCard('المستوى الدراسي', _student.grade),
              _buildInfoCard('الفصل', _student.classId),
              _buildInfoCard('الفرع', _student.branch),
              _buildInfoCard('رقم الهاتف', _student.phone),
              _buildInfoCard('البريد الإلكتروني', _student.email),
              _buildInfoCard('العنوان', _student.address),
              _buildInfoCard('ولي الأمر', _student.guardianName),
              _buildInfoCard('هاتف ولي الأمر', _student.guardianPhone),
              _buildInfoCard('قيمة القسط', '${_student.installmentValue} ل.س'),
              if (_student.notes.isNotEmpty)
                _buildInfoCard('ملاحظات', _student.notes),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _toggleActiveStatus(),
                      icon: Icon(
                        _student.isActive ? Icons.block : Icons.check_circle,
                        color: Colors.white,
                      ),
                      label: Text(
                        _student.isActive ? 'تعطيل الحساب' : 'تنشيط الحساب',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _student.isActive ? Colors.red : Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showChangeEmailDialog(),
                      icon: const Icon(Icons.email, color: Colors.white),
                      label: const Text(
                        'تغيير البريد',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showChangePasswordDialog(),
                  icon: const Icon(Icons.lock, color: Colors.white),
                  label: const Text(
                    'تغيير كلمة المرور',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Expanded(
              child: Text(
                value.isNotEmpty ? value : 'غير محدد',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleActiveStatus() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد'),
        content: Text(
          _student.isActive
              ? 'هل أنت متأكد من تعطيل حساب هذا الطالب؟ لن يتمكن من تسجيل الدخول.'
              : 'هل أنت متأكد من تنشيط حساب هذا الطالب؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              _student.isActive ? 'تعطيل' : 'تنشيط',
              style: TextStyle(
                color: _student.isActive ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final newStatus = !_student.isActive;
        await FirestoreRefs.students.doc(_student.uid).update({
          'isActive': newStatus,
        });
        await ref.read(adminRepositoryProvider).setAccountActive(
              uid: _student.uid,
              isActive: newStatus,
            );
        setState(() {
          _student = _student.copyWith(isActive: newStatus);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(newStatus ? 'تم تنشيط الحساب' : 'تم تعطيل الحساب'),
              backgroundColor: Colors.green,
            ),
          );
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
      }
    }
  }

  void _showChangeEmailDialog() {
    final newEmailController = TextEditingController(text: _student.email);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير البريد الإلكتروني'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('البريد الإلكتروني الحالي:'),
            Text(
              _student.email,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني الجديد',
                border: OutlineInputBorder(),
              ),
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
              final newEmail = newEmailController.text.trim();
              if (newEmail.isEmpty || !newEmail.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('البريد الإلكتروني غير صالح'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await FirestoreRefs.students.doc(_student.uid).update({
                  'email': newEmail,
                });
                await FirestoreRefs.users.doc(_student.uid).update({
                  'email': newEmail,
                });
                setState(() {
                  _student = _student.copyWith(email: newEmail);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث البريد الإلكتروني بنجاح'),
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
    );
  }

  void _showChangePasswordDialog() {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                border: OutlineInputBorder(),
              ),
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
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;

              if (newPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمة المرور يجب أن تكون 6 أحرف على الأقل'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمتا المرور غير متطابقتين'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await ref.read(authServiceProvider).resetPasswordForAdmin(
                      uid: _student.uid,
                      newPassword: newPassword,
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال رابط إعادة تعيين كلمة المرور إلى البريد الإلكتروني'),
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
    );
  }
}
