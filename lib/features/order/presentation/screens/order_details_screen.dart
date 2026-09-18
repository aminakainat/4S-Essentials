import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_4sessentials/core/theme.dart';
import 'package:flutter_4sessentials/core/services/pdf_invoice_service.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final String orderId;
  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'Pending';
    final items = order['items'] as List<dynamic>? ?? [];
    final totalPrice = order['totalPrice'] ?? '\$0.00';
    final paymentMethod = order['paymentMethod'] ?? 'COD';
    final address = order['shippingAddress'] ?? 'Standard Delivery';
    final userName = order['userName'] ?? 'Customer';
    int activeStep = 0;
    if (status == 'Shipped') activeStep = 2;
    if (status == 'Delivered') activeStep = 3;
    if (status == 'Processing') activeStep = 1;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'ORDER DETAILS & TRACKING',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            color: context.textColor,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20.sp,
            color: context.textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: context.isDarkMode ? 0.2 : 0.01,
                    ),
                    blurRadius: 10,
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
                          fontSize: 16.sp,
                          color: context.textColor,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRose.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                            color: AppTheme.primaryRose,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  ...items.map((item) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${item['name']} (x${item['qty']})",
                              style: GoogleFonts.outfit(
                                color: context.textColor,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                          Text(
                            item['price'] ?? '',
                            style: GoogleFonts.outfit(
                              color: context.textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Paid',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: context.textColor,
                        ),
                      ),
                      Text(
                        totalPrice,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w900,
                          fontSize: 16.sp,
                          color: AppTheme.primaryRose,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),

            Text(
              'Shipping Progress',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: context.textColor,
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Column(
                children: [
                  _timelineStep(
                    'Ordered Successfully',
                    'Your order is placed and confirmed.',
                    activeStep >= 0,
                    isLast: false,
                  ),
                  _timelineStep(
                    'Processing in Warehouse',
                    'Jewelry undergoes quality checks and custom settings.',
                    activeStep >= 1,
                    isLast: false,
                  ),
                  _timelineStep(
                    'Shipped with Carrier',
                    'Dispatched with tracking details.',
                    activeStep >= 2,
                    isLast: false,
                  ),
                  _timelineStep(
                    'Out for Delivery / Completed',
                    'Handed over to customer.',
                    activeStep >= 3,
                    isLast: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 35.h),

            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  PdfInvoiceService.generateAndShareInvoice(
                    orderId: orderId,
                    userName: userName,
                    items: items,
                    totalPrice: totalPrice,
                    paymentMethod: paymentMethod,
                    address: address,
                  );
                },
                icon: const Icon(Icons.download_rounded, color: Colors.white),
                label: Text(
                  'DOWNLOAD PDF INVOICE',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRose,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineStep(
    String title,
    String description,
    bool isActive, {
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryRose : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: isActive
                  ? const Icon(Icons.check, color: Colors.white, size: 10)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 50.h,
                color: isActive ? AppTheme.primaryRose : Colors.grey.shade300,
              ),
          ],
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                  color: isActive ? AppTheme.primaryRose : Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: GoogleFonts.outfit(
                  color: Colors.grey.shade500,
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 25.h),
            ],
          ),
        ),
      ],
    );
  }
}
