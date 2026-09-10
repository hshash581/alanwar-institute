import 'package:flutter/material.dart';
import 'package:alanwar_institute/core/constants/app_colors.dart';
import 'package:alanwar_institute/core/services/firebase_refs.dart';
import 'package:alanwar_institute/core/widgets/state_widgets.dart';
import 'package:alanwar_institute/core/widgets/common_cards.dart';
import 'package:alanwar_institute/models/student_model.dart';
import 'package:alanwar_institute/models/records_model.dart';

class PaymentsScreen extends StatelessWidget {
  final StudentModel student;

  const PaymentsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الدفعات',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
        body: StreamBuilder<List<PaymentRecord>>(
          stream: FirestoreRefs.payments
              .where('studentId', isEqualTo: student.uid)
              .snapshots()
              .map((snapshot) {
            return snapshot.docs.map((doc) {
              return PaymentRecord.fromMap(doc.data() as Map<String, dynamic>);
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

            final payments = snapshot.data ?? [];

            if (payments.isEmpty) {
              return const EmptyView(
                message: 'لا توجد دفعات',
                icon: Icons.payment,
              );
            }

            final totalExpected = student.installmentValue * 12;
            final totalPaid = payments.fold<double>(
              0,
              (sum, p) => sum + p.paidAmount,
            );
            final totalRemaining = totalExpected - totalPaid;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
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
                          title: 'المدفوع',
                          iconColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatCard(
                          icon: Icons.pending,
                          value: '$totalRemaining ل.س',
                          title: 'المتبقي',
                          iconColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return _buildPaymentCard(payment);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentCard(PaymentRecord payment) {
    Color statusColor;
    String statusText;

    switch (payment.status) {
      case PaymentStatus.paid:
        statusColor = Colors.green;
        statusText = 'مدفوع';
        break;
      case PaymentStatus.unpaid:
        statusColor = Colors.red;
        statusText = 'غير مدفوع';
        break;
      case PaymentStatus.partial:
        statusColor = Colors.orange;
        statusText = 'جزئي';
        break;
      case PaymentStatus.overdue:
        statusColor = Colors.red;
        statusText = 'متأخر';
        break;
    }

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
                  text: statusText,
                  color: statusColor,
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
}
