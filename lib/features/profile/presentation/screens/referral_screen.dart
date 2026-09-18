import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_4sessentials/core/theme.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  String _referralCode = '4S-JEWEL-779';
  bool _loading = true;
  int _referralCount = 0;
  double _earnings = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Create a unique code if it doesn't exist or fetch it
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      try {
        final doc = await userRef.get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            setState(() {
              _referralCode = data['referralCode'] ?? '4S-${user.uid.substring(0, 5).toUpperCase()}';
              _referralCount = data['referralCount'] ?? 0;
              _earnings = (data['referralEarnings'] ?? 0.0).toDouble();
              _loading = false;
            });
            return;
          }
        }
      } catch (e) {
        // Fallback/ignoring errors
      }
    }
    setState(() {
      _loading = false;
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral code copied to clipboard!', style: GoogleFonts.outfit()),
        backgroundColor: AppTheme.primaryRose,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareCode() {
    final text = 'Discover premium artisanal jewelry at 4S Essentials! Use my referral code: $_referralCode to get a 15% discount on your first order. Download the app today!';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'REFERRAL PROGRAM',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: context.textColor,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: context.textColor),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
              child: Column(
                children: [
                  // Premium Banner Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(25.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryRose,
                          AppTheme.primaryRose.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRose.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite Friends &\nEarn Rewards',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Share the love of luxury jewelry. When they make their first purchase using your code, they get 15% off and you get \$20 wallet credit.',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.sp,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),

                  // Referral Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Total Invites',
                                style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 13.sp),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                '$_referralCount',
                                style: GoogleFonts.outfit(
                                  color: context.textColor,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Earnings',
                                style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 13.sp),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                '\$${_earnings.toStringAsFixed(2)}',
                                style: GoogleFonts.outfit(
                                  color: AppTheme.primaryRose,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 35.h),

                  // Referral Code Container
                  Text(
                    'YOUR UNIQUE REFERRAL CODE',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: context.subtextColor,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 15.w),
                        Expanded(
                          child: Text(
                            _referralCode,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                              color: context.textColor,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _copyToClipboard,
                          icon: Icon(Icons.copy_rounded, color: AppTheme.primaryRose, size: 20.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),

                  // Share button
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton.icon(
                      onPressed: _shareCode,
                      icon: const Icon(Icons.share_rounded, color: Colors.white),
                      label: Text(
                        'SHARE REFERRAL CODE',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14.sp,
                          letterSpacing: 1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRose,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Info Steps
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'How it works',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: context.textColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildStepRow(
                    context,
                    '1',
                    'Share your link or code',
                    'Send the code or a referral link to your friends.',
                  ),
                  _buildStepRow(
                    context,
                    '2',
                    'They buy premium jewelry',
                    'They register and get 15% discount on their checkout order.',
                  ),
                  _buildStepRow(
                    context,
                    '3',
                    'You receive rewards',
                    'Once verified, \$20 is added directly to your wallet account.',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStepRow(BuildContext context, String num, String title, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryRose.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              num,
              style: GoogleFonts.outfit(
                color: AppTheme.primaryRose,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
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
                    color: context.textColor,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  desc,
                  style: GoogleFonts.outfit(
                    color: context.subtextColor,
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
