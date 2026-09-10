import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alanwar_institute/core/services/providers.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/core/widgets/common_cards.dart';
import 'package:alanwar_institute/models/student_model.dart';
import 'package:alanwar_institute/models/records_model.dart';

class ManagePaymentsScreen extends ConsumerStatefulWidget {
  const ManagePaymentsScreen({super.key});

  @override
  ConsumerState<ManagePaymentsScreen> createState() => _ManagePaymentsScreenState();
}

class _ManagePaymentsScreenState extends ConsumerState<ManagePaymentsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'إدارة الدفعات',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildStudentsList(),
            _buildReportsTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'الطلاب',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: 'التقارير',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    return StreamBuilder<List<StudentModel>>(
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

        final students = snapshot.data ?? [];

        if (students.isEmpty) {
          return const EmptyView(
            message: 'لا يوجد طلاب',
            icon: Icons.people_outline,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return _buildStudentPaymentCard(student);
          },
        );
      },
    );
  }

  Widget _buildStudentPaymentCard(StudentModel student) {
    return StreamBuilder<List<PaymentRecord>>(
      stream: FirestoreRefs.payments
          .where('studentId', isEqualTo: student.uid)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return PaymentRecord.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      }),
      builder: (context, snapshot) {
        final payments = snapshot.data ?? [];
        final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.paidAmount);
        final totalExpected = student.installmentValue * 12;
        final remaining = totalExpected - totalPaid;

        PaymentStatus status;
        if (totalPaid >= totalExpected) {
          status = PaymentStatus.paid;
        } else if (totalPaid > 0) {
          status = PaymentStatus.partial;
        } else {
          status = PaymentStatus.unpaid;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                student.studentNumber.substring(student.studentNumber.length - 2),
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            title: Text(
              student.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('القسط الشهري: ${student.installmentValue} ل.س'),
                Text('المدفوع: $totalPaid ل.س'),
                Text('المتبقي: $remaining ل.س'),
              ],
            ),
            trailing: StatusBadge(
              text: _getStatusText(status),
              color: _getStatusColor(status),
            ),
            isThreeLine: true,
            onTap: () => _showStudentPayments(student, payments),
          ),
        );
      },
    );
  }

  void _showStudentPayments(StudentModel student, List<PaymentRecord> payments) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'دفعات ${student.fullName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: payments.isEmpty
                  ? const EmptyView(
                      message: 'لا توجد دفعات',
                      icon: Icons.payment,
                    )
                  : ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        return _buildPaymentCard(payment);
                      },
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showRecordPaymentDialog(student);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'تسجيل دفعة جديدة',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentRecord payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'القسط: ${payment.totalValue} ل.س',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                StatusBadge(
                  text: _getStatusText(payment.status),
                  color: _getStatusColor(payment.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('المدفوع: ${payment.paidAmount} ل.س'),
            Text('المتبقي: ${payment.remaining} ل.س'),
            if (payment.dueDate != null)
              Text(
                'تاريخ الاستحقاق: ${payment.dueDate!.day}/${payment.dueDate!.month}/${payment.dueDate!.year}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  void _showRecordPaymentDialog(StudentModel student) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل دفعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('الطالب: ${student.fullName}'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                border: OutlineInputBorder(),
                suffixText: 'ل.س',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
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
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى إدخال مبلغ صحيح'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final currentUser = ref.read(currentAppUserProvider).value;
                final transaction = PaymentTransaction(
                  amount: amount,
                  date: DateTime.now(),
                  recordedBy: currentUser?.uid ?? '',
                  note: noteController.text.trim(),
                );

                final paymentsQuery = await FirestoreRefs.payments
                    .where('studentId', isEqualTo: student.uid)
                    .get();

                if (paymentsQuery.docs.isNotEmpty) {
                  final paymentDoc = paymentsQuery.docs.first;
                  final paymentData = paymentDoc.data() as Map<String, dynamic>;
                  final currentPaid = (paymentData['paidAmount'] ?? 0).toDouble();
                  final totalValue = (paymentData['totalValue'] ?? 0).toDouble();
                  final newPaid = currentPaid + amount;

                  PaymentStatus newStatus;
                  if (newPaid >= totalValue) {
                    newStatus = PaymentStatus.paid;
                  } else if (newPaid > 0) {
                    newStatus = PaymentStatus.partial;
                  } else {
                    newStatus = PaymentStatus.unpaid;
                  }

                  final existingTransactions = List<Map<String, dynamic>>.from(
                    paymentData['transactions'] ?? [],
                  );
                  existingTransactions.add(transaction.toMap());

                  await FirestoreRefs.payments.doc(paymentDoc.id).update({
                    'paidAmount': newPaid,
                    'status': newStatus.name,
                    'transactions': existingTransactions,
                  });
                } else {
                  final docRef = FirestoreRefs.payments.doc();
                  await docRef.set({
                    'id': docRef.id,
                    'studentId': student.uid,
                    'totalValue': student.installmentValue * 12,
                    'paidAmount': amount,
                    'dueDate': DateTime.now().add(const Duration(days: 365)),
                    'status': amount >= student.installmentValue * 12
                        ? PaymentStatus.paid.name
                        : PaymentStatus.partial.name,
                    'transactions': [transaction.toMap()],
                    'notes': noteController.text.trim(),
                  });
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تسجيل الدفعة بنجاح'),
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
            child: const Text('تسجيل'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return StreamBuilder<List<StudentModel>>(
      stream: ref.watch(studentsStreamProvider).whenData((data) => Stream.value(data)).value,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingView();
        }

        final students = snapshot.data ?? [];

        return StreamBuilder<List<PaymentRecord>>(
          stream: FirestoreRefs.payments.snapshots().map((snapshot) {
            return snapshot.docs.map((doc) {
              return PaymentRecord.fromMap(doc.data() as Map<String, dynamic>);
            }).toList();
          }),
          builder: (context, paymentSnapshot) {
            final payments = paymentSnapshot.data ?? [];

            final totalExpected = students.fold<double>(
              0,
              (sum, s) => sum + (s.installmentValue * 12),
            );
            final totalPaid = payments.fold<double>(
              0,
              (sum, p) => sum + p.paidAmount,
            );
            final totalRemaining = totalExpected - totalPaid;
            final collectionRate = totalExpected > 0
                ? (totalPaid / totalExpected * 100).toStringAsFixed(1)
                : '0';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ملخص التحصيل',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.attach_money,
                          value: '$totalExpected ل.س',
                          title: 'المتوقع',
                          iconColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icon: Icons.check_circle,
                          value: '$totalPaid ل.س',
                          title: 'المتحصل',
                          iconColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.pending,
                          value: '$totalRemaining ل.س',
                          title: 'المتبقي',
                          iconColor: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icon: Icons.percent,
                          value: '$collectionRate%',
                          title: 'نسبة التحصيل',
                          iconColor: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.unpaid:
        return 'غير مدفوع';
      case PaymentStatus.partial:
        return 'جزئي';
      case PaymentStatus.overdue:
        return 'متأخر';
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.unpaid:
        return Colors.red;
      case PaymentStatus.partial:
        return Colors.orange;
      case PaymentStatus.overdue:
        return Colors.red;
    }
  }
}
