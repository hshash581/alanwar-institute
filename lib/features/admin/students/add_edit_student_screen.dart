import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/models/class_subject_schedule_model.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';

class AddEditStudentScreen extends ConsumerStatefulWidget {
  final String? studentId;

  const AddEditStudentScreen({super.key, this.studentId});

  @override
  ConsumerState<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends ConsumerState<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _installmentController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedSemester;
  String? _selectedClassLevel;
  String? _selectedStreamId;
  List<String> _selectedSubjectIds = [];
  bool _isLoading = false;

  final List<String> _semesters = ['الفصل الأول', 'الفصل الثاني'];
  final List<String> _classLevels = ['تاسع', 'بكالوريا'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _installmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamsAsync = ref.watch(streamsStreamProvider);
    final subjectsAsync = ref.watch(subjectsStreamProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.studentId == null ? 'إضافة طالب جديد' : 'تعديل بيانات الطالب',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال الاسم';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'رقم الهاتف',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال رقم الهاتف';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    if (!value.contains('@')) {
                      return 'البريد الإلكتروني غير صالح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedClassLevel,
                  decoration: InputDecoration(
                    labelText: 'المستوى الدراسي',
                    prefixIcon: const Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: _classLevels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClassLevel = value;
                      _selectedStreamId = null;
                      _selectedSubjectIds = [];
                    });
                  },
                  validator: (value) {
                    if (value == null) return 'الرجاء اختيار المستوى الدراسي';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedSemester,
                  decoration: InputDecoration(
                    labelText: 'الفصل الدراسي',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: _semesters.map((semester) {
                    return DropdownMenuItem(
                      value: semester,
                      child: Text(semester),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedSemester = value);
                  },
                  validator: (value) {
                    if (value == null) return 'الرجاء اختيار الفصل الدراسي';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                streamsAsync.when(
                  data: (streams) {
                    final filteredStreams = _selectedClassLevel != null
                        ? streams.where((s) => s.classLevel == _selectedClassLevel).toList()
                        : streams;

                    return DropdownButtonFormField<String>(
                      value: _selectedStreamId,
                      decoration: InputDecoration(
                        labelText: 'الشعب/البرنامج',
                        prefixIcon: const Icon(Icons.account_tree),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: filteredStreams.map((stream) {
                        return DropdownMenuItem(
                          value: stream.id,
                          child: Text(stream.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStreamId = value;
                          _selectedSubjectIds = [];
                        });
                      },
                      validator: (value) {
                        if (value == null) return 'الرجاء اختيار الشعب/البرنامج';
                        return null;
                      },
                    );
                  },
                  loading: () => const LoadingView(),
                  error: (_, __) => const Text('خطأ في تحميل الشعب'),
                ),
                const SizedBox(height: 16),
                subjectsAsync.when(
                  data: (subjects) {
                    final filteredSubjects = _selectedClassLevel != null
                        ? subjects.where((s) => s.classLevel == _selectedClassLevel).toList()
                        : subjects;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'المواد الدراسية',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (filteredSubjects.isEmpty)
                          const Text(
                            'لا توجد مواد لهذا المستوى',
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: filteredSubjects.map((subject) {
                              final isSelected = _selectedSubjectIds.contains(subject.id);
                              return FilterChip(
                                label: Text(subject.name),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedSubjectIds.add(subject.id);
                                    } else {
                                      _selectedSubjectIds.remove(subject.id);
                                    }
                                  });
                                },
                                selectedColor: AppColors.primary.withOpacity(0.2),
                              );
                            }).toList(),
                          ),
                      ],
                    );
                  },
                  loading: () => const LoadingView(),
                  error: (_, __) => const Text('خطأ في تحميل المواد'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _addressController,
                  label: 'العنوان',
                  icon: Icons.home,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _guardianNameController,
                  label: 'اسم ولي الأمر',
                  icon: Icons.family_restroom,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _guardianPhoneController,
                  label: 'هاتف ولي الأمر',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _installmentController,
                  label: 'قيمة القسط',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _notesController,
                  label: 'ملاحظات',
                  icon: Icons.notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveStudent,
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
                            'حفظ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final adminRepo = ref.read(adminRepositoryProvider);
      final currentUser = ref.read(currentAppUserProvider).value;

      if (currentUser == null) throw Exception('غير مصرح');

      final credentials = await adminRepo.createStudent(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        semester: _selectedSemester!,
        classLevel: _selectedClassLevel!,
        streamId: _selectedStreamId!,
        address: _addressController.text.trim(),
        guardianName: _guardianNameController.text.trim(),
        guardianPhone: _guardianPhoneController.text.trim(),
        subjectIds: _selectedSubjectIds,
        installmentValue: double.tryParse(_installmentController.text) ?? 0,
        notes: _notesController.text.trim(),
        createdBy: currentUser.uid,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تم الإنشاء بنجاح'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('تم إنشاء حساب الطالب بنجاح'),
                const SizedBox(height: 16),
                Text('رقم الطالب: ${credentials.displayName.split(' - ').first}'),
                const SizedBox(height: 8),
                Text('البريد الإلكتروني: ${credentials.email}'),
                const SizedBox(height: 8),
                Text('كلمة المرور: ${credentials.password}'),
                const SizedBox(height: 16),
                const Text(
                  'يرجى حفظ هذه البيانات في مكان آمن',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
