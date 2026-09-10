import 'package:flutter/material.dart';
import 'package:al_anwar_institute/core/constants/app_colors.dart';
import 'package:al_anwar_institute/core/services/firebase_refs.dart';
import 'package:al_anwar_institute/core/widgets/state_widgets.dart';
import 'package:al_anwar_institute/models/records_model.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الإعلانات',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
        body: StreamBuilder<List<AnnouncementModel>>(
          stream: FirestoreRefs.announcements.snapshots().map((snapshot) {
            return snapshot.docs.map((doc) {
              return AnnouncementModel.fromMap(doc.data() as Map<String, dynamic>);
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

            final announcements = snapshot.data ?? [];

            if (announcements.isEmpty) {
              return const EmptyView(
                message: 'لا توجد إعلانات',
                icon: Icons.announcement,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final announcement = announcements[index];
                return _buildAnnouncementCard(announcement);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              announcement.body,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.public,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _getTargetText(announcement.target),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                if (announcement.createdAt != null)
                  Text(
                    '${announcement.createdAt!.day}/${announcement.createdAt!.month}/${announcement.createdAt!.year}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTargetText(AnnouncementTarget target) {
    switch (target) {
      case AnnouncementTarget.all:
        return 'الجميع';
      case AnnouncementTarget.classId:
        return 'فصل محدد';
      case AnnouncementTarget.subject:
        return 'مادة محددة';
      case AnnouncementTarget.teachers:
        return 'المعلمون فقط';
    }
  }
}
