import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_4sessentials/core/theme.dart';
import 'package:flutter_4sessentials/core/services/firestore_service.dart';
import 'package:flutter_4sessentials/features/order/presentation/screens/order_details_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return '';
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Recent';
    final dt = timestamp.toDate();
    return "${dt.day} ${_getMonthName(dt.month)}, ${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: context.scaffoldBg,
        appBar: AppBar(
          title: Text(
            'Order History',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, color: context.textColor),
          ),
        ),
        body: Center(
          child: Text(
            'Please log in to view your orders.',
            style: GoogleFonts.outfit(
              color: context.subtextColor,
              fontSize: 16.sp,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'ORDER HISTORY',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: context.textColor,
            letterSpacing: 1.2,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: context.textColor),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getUserOrdersStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB9937E)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load orders: ${snapshot.error}',
                style: GoogleFonts.outfit(
                  color: Colors.redAccent,
                  fontSize: 14.sp,
                ),
              ),
            );
          }

          final orderDocs = snapshot.data?.docs ?? [];
          if (orderDocs.isEmpty) {
            return Center(
              child: FadeIn(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(30.w),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: context.isDarkMode ? 0.2 : 0.02,
                            ),
                            blurRadius: 10.r,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 60.sp,
                        color: context.subtextColor.withValues(alpha: 0.5),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'No Orders Placed Yet',
                      style: GoogleFonts.outfit(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Explore our premium catalog to make your first order.',
                      style: GoogleFonts.outfit(
                        color: context.subtextColor,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
            itemCount: orderDocs.length,
            itemBuilder: (context, index) {
              final doc = orderDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final orderId = doc.id.substring(0, 6).toUpperCase();
              final timestamp = data['createdAt'] as Timestamp?;
              final dateStr = _formatTimestamp(timestamp);
              final totalPrice = data['totalPrice'] ?? '\$0.00';
              final status = data['status'] ?? 'Pending';

              final items = data['items'] as List<dynamic>? ?? [];
              final itemsSummary = items
                  .map((e) {
                    final name = e['name'] ?? '';
                    final qty = e['qty'] ?? 1;
                    return "$name (x$qty)";
                  })
                  .join(', ');

              return FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailsScreen(order: data, orderId: doc.id),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 20.h),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(25.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: context.isDarkMode ? 0.2 : 0.02,
                          ),
                          blurRadius: 10.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #$orderId',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: context.textColor,
                                fontSize: 16.sp,
                              ),
                            ),
                            _buildStatusBadge(status),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          itemsSummary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: context.subtextColor,
                            fontSize: 14.sp,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          child: Divider(height: 1, color: context.borderColor),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ORDER DATE',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFB9937E),
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  dateStr,
                                  style: GoogleFonts.outfit(
                                    color: context.textColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'TOTAL PAYMENT',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFB9937E),
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  totalPrice,
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.primaryRose,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Delivered':
        color = Colors.green;
        break;
      case 'Shipped':
        color = Colors.blue;
        break;
      case 'Cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
