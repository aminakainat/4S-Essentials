import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_4sessentials/core/theme.dart';

class CouponManagementScreen extends StatefulWidget {
  const CouponManagementScreen({super.key});

  @override
  State<CouponManagementScreen> createState() => _CouponManagementScreenState();
}

class _CouponManagementScreenState extends State<CouponManagementScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();
  bool _isActive = true;

  @override
  void dispose() {
    _codeController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _createCoupon() async {
    final code = _codeController.text.trim().toUpperCase();
    final discount = double.tryParse(_discountController.text.trim()) ?? 0.0;

    if (code.isEmpty || discount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid code and discount rate'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    try {
      await _db.collection('coupons').add({
        'code': code,
        'discountPercent': discount,
        'isActive': _isActive,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _codeController.clear();
      _discountController.clear();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coupon created successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _toggleCoupon(String docId, bool currentStatus) async {
    try {
      await _db.collection('coupons').doc(docId).update({
        'isActive': !currentStatus,
      });
    } catch (e) {
      debugPrint('Error toggling coupon: $e');
    }
  }

  void _deleteCoupon(String docId) async {
    try {
      await _db.collection('coupons').doc(docId).delete();
    } catch (e) {
      debugPrint('Error deleting coupon: $e');
    }
  }

  void _showCreateDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 30.h),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Promotional Coupon',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18.sp, color: context.textColor),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.outfit(color: context.textColor),
                  decoration: InputDecoration(
                    hintText: 'COUPON CODE (e.g. SILVER15)',
                    hintStyle: GoogleFonts.outfit(color: context.subtextColor, fontSize: 13.sp),
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.outfit(color: context.textColor),
                  decoration: InputDecoration(
                    hintText: 'Discount Percentage (e.g. 15)',
                    hintStyle: GoogleFonts.outfit(color: context.subtextColor, fontSize: 13.sp),
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Active immediately', style: GoogleFonts.outfit(color: context.textColor, fontSize: 13.sp)),
                    Switch(
                      value: _isActive,
                      activeColor: AppTheme.primaryRose,
                      onChanged: (val) {
                        setModalState(() {
                          _isActive = val;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 25.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _createCoupon,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
                    child: Text('CREATE COUPON', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'COUPON MANAGEMENT',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15.sp, color: context.textColor, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: context.textColor),
        ),
        actions: [
          IconButton(
            onPressed: _showCreateDialog,
            icon: Icon(Icons.add, color: AppTheme.primaryRose, size: 24.sp),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection('coupons').orderBy('createdAt', descending: true).snapshots(),
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
                  Icon(Icons.local_offer_outlined, size: 60.sp, color: context.subtextColor),
                  SizedBox(height: 15.h),
                  Text('No promo codes created yet', style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 13.sp)),
                  SizedBox(height: 15.h),
                  ElevatedButton(
                    onPressed: _showCreateDialog,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
                    child: Text('Create First Coupon', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
              final code = data['code'] ?? '';
              final pct = (data['discountPercent'] as num? ?? 0).toDouble();
              final active = data['isActive'] as bool? ?? true;
              final docId = docs[index].id;

              return Container(
                margin: EdgeInsets.only(bottom: 15.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.01), blurRadius: 10)
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(color: AppTheme.primaryRose.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.local_offer, color: AppTheme.primaryRose, size: 20.sp),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(code, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: context.textColor, fontSize: 15.sp)),
                          SizedBox(height: 4.h),
                          Text('$pct% Discount Rate', style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp)),
                        ],
                      ),
                    ),
                    Switch(
                      value: active,
                      activeColor: AppTheme.primaryRose,
                      onChanged: (val) => _toggleCoupon(docId, active),
                    ),
                    IconButton(
                      onPressed: () => _deleteCoupon(docId),
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
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
