import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_anwar_institute/core/services/providers.dart';
import 'package:al_anwar_institute/core/services/firebase_refs.dart';
import 'package:al_anwar_institute/core/constants/app_colors.dart';
import 'package:al_anwar_institute/core/widgets/state_widgets.dart';
import 'package:al_anwar_institute/core/widgets/common_cards.dart';
import 'package:al_anwar_institute/models/student_model.dart';
import 'package:al_anwar_institute/models/records_model.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'التقارير',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'التقارير المالية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFinancialSummary(),
              const SizedBox(height: 24),
              const Text(
                'تفاصيل بالطالب',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildStudentBreakdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummary() {
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

            return Column(
              children: [
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
            );
          },
        );
      },
    );
  }

  Widget _buildStudentBreakdown() {
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

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final studentPayments = payments
                    .where((p) => p.studentId == student.uid)
                    .toList();
                final totalPaid = studentPayments.fold<double>(
                  0,
                  (sum, p) => sum + p.paidAmount,
                );
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
                        Text('المتوقع: $totalExpected ل.س'),
                        Text('المدفوع: $totalPaid ل.س'),
                        Text('المتبقي: $remaining ل.س'),
                      ],
                    ),
                    trailing: StatusBadge(
                      text: _getStatusText(status),
                      color: _getStatusColor(status),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
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
