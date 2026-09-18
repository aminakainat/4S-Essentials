import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_4sessentials/core/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final dt = timestamp.toDate();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} - ${dt.day}/${dt.month}/${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        body: Center(
          child: Text('Please log in to view notifications', style: GoogleFonts.outfit(color: context.textColor)),
        ),
      );
    }

    final FirebaseFirestore db = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'NOTIFICATIONS',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp, color: context.textColor, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: context.textColor),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('notifications')
            .where('userId', whereIn: [user.uid, 'all'])
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 60.sp, color: context.subtextColor),
                  SizedBox(height: 15.h),
                  Text(
                    'Your Notification Center is empty.',
                    style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 14.sp),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Notification';
              final body = data['body'] ?? '';
              final type = data['type'] ?? 'info'; // 'order', 'referral', 'promo', 'info'
              final timestamp = data['timestamp'] as Timestamp?;

              IconData icon;
              Color iconColor;
              switch (type) {
                case 'order':
                  icon = Icons.shopping_bag_outlined;
                  iconColor = Colors.blue;
                  break;
                case 'referral':
                  icon = Icons.people_outline;
                  iconColor = Colors.green;
                  break;
                case 'promo':
                  icon = Icons.local_offer_outlined;
                  iconColor = Colors.amber;
                  break;
                default:
                  icon = Icons.info_outline;
                  iconColor = AppTheme.primaryRose;
              }

              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.01),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 20.sp),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: context.textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            body,
                            style: GoogleFonts.outfit(
                              color: context.subtextColor,
                              fontSize: 12.sp,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _formatTimestamp(timestamp),
                            style: GoogleFonts.outfit(
                              color: context.subtextColor.withValues(alpha: 0.7),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
