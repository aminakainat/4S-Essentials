import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_4sessentials/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_4sessentials/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:flutter_4sessentials/features/profile/presentation/screens/help_center_screen.dart';
import 'package:flutter_4sessentials/features/order/presentation/screens/order_history_screen.dart';
import 'package:flutter_4sessentials/core/theme.dart';
import 'package:flutter_4sessentials/core/services/auth_service.dart';
import 'package:flutter_4sessentials/features/profile/presentation/screens/addresses_screen.dart';
import 'package:flutter_4sessentials/features/profile/presentation/screens/referral_screen.dart';
import 'package:flutter_4sessentials/features/profile/presentation/screens/live_chat_screen.dart';
import 'package:flutter_4sessentials/features/profile/presentation/screens/notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userPhone;
  final dynamic userImage;
  final Function(String, String, dynamic) onUpdate;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userPhone,
    this.userImage,
    required this.onUpdate,
  });

  Widget _buildUserImage(BuildContext context) {
    if (userImage == null) {
      return Icon(
        Icons.person_rounded,
        size: 60.sp,
        color: AppTheme.primaryRose,
      );
    }
    if (kIsWeb) {
      final String path = userImage is File
          ? userImage.path
          : userImage.toString();
      return Image.network(path, fit: BoxFit.cover);
    } else {
      final File file = userImage is File
          ? userImage as File
          : File(userImage.toString());
      return Image.file(file, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(25.w),
        child: Column(
          children: [
            SizedBox(height: 50.h),

            FadeInDown(
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.surfaceColor,
                          width: 5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: context.isDarkMode ? 0.2 : 0.05,
                            ),
                            blurRadius: 20.r,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60.r),
                        child: _buildUserImage(context),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      userName,
                      style: GoogleFonts.outfit(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                    Text(
                      userPhone,
                      style: GoogleFonts.outfit(
                        color: context.subtextColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),

            FadeInUp(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: context.isDarkMode ? 0.2 : 0.02,
                      ),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      Icons.person_outline,
                      'Edit Profile',
                      onTap: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        final userEmail = user?.email ?? 'sanjida@example.com';
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              currentName: userName,
                              currentEmail: userEmail,
                              currentPhone: userPhone,
                              currentImage: userImage,
                            ),
                          ),
                        );
                        if (result != null) {
                          onUpdate(
                            result['name'],
                            result['phone'],
                            result['image'],
                          );
                        }
                      },
                    ),
                    _buildMenuItem(
                      context,
                      Icons.shopping_bag_outlined,
                      'My Orders',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrderHistoryScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      Icons.location_on_outlined,
                      'Shipping Addresses',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddressesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      Icons.share_outlined,
                      'Referral Program',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReferralScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      Icons.notifications_none,
                      'Notifications',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      Icons.chat_bubble_outline_rounded,
                      'Live Support Chat',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LiveChatScreen(),
                          ),
                        );
                      },
                    ),
                    _buildThemeToggleItem(context),
                    _buildMenuItem(
                      context,
                      Icons.help_outline,
                      'Help & Support',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpCenterScreen(),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Divider(color: context.borderColor),
                    ),
                    _buildMenuItem(
                      context,
                      Icons.logout,
                      'Log Out',
                      isLast: true,
                      color: Colors.redAccent,
                      onTap: () async {
                        try {
                          await AuthService().signOut();
                          if (context.mounted) {
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logout failed: $e'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggleItem(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeModeNotifier,
      builder: (context, currentMode, _) {
        final isDark = currentMode == ThemeMode.dark;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRose.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  size: 22.sp,
                  color: AppTheme.primaryRose,
                ),
              ),
              SizedBox(width: 20.w),
              Text(
                'Dark Mode',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: context.textColor,
                ),
              ),
              const Spacer(),
              Switch(
                value: isDark,
                activeColor: AppTheme.primaryRose,
                onChanged: (val) {
                  ThemeManager.toggleTheme();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title, {
    bool isLast = false,
    Color? color,
    VoidCallback? onTap,
  }) {
    final displayColor = color ?? context.textColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: displayColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 22.sp, color: displayColor),
            ),
            SizedBox(width: 20.w),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: displayColor,
              ),
            ),
            const Spacer(),
            if (!isLast)
              Icon(
                Icons.arrow_forward_ios,
                size: 14.sp,
                color: context.subtextColor.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfileDetailScreen extends StatelessWidget {
  final String title;
  const ProfileDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    bool isHelp = title == 'Help & Support';

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: context.textColor,
            fontSize: 20.sp,
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
      body: Center(
        child: FadeInUp(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(30.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRose.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isHelp
                      ? Icons.support_agent_rounded
                      : Icons.settings_suggest_outlined,
                  size: 80.sp,
                  color: AppTheme.primaryRose,
                ),
              ),
              SizedBox(height: 30.h),
              Text(
                isHelp ? 'Dedicated Support' : '$title Details',
                style: GoogleFonts.outfit(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                isHelp
                    ? '24/7 Helpline available for you'
                    : 'This section is coming soon!',
                style: GoogleFonts.outfit(
                  color: context.subtextColor,
                  fontSize: 14.sp,
                ),
              ),
              if (isHelp) ...[
                const SizedBox(height: 40),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 20.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: context.isDarkMode ? 0.2 : 0.01,
                        ),
                        blurRadius: 10.r,
                        offset: Offset(0, 5.h),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRose.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.phone_in_talk,
                          color: AppTheme.primaryRose,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Helpline Number',
                              style: GoogleFonts.outfit(
                                color: context.subtextColor,
                                fontSize: 13.sp,
                              ),
                            ),
                            Text(
                              '+92 300 123 4567',
                              style: GoogleFonts.outfit(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                SizedBox(
                  width: 200.w,
                  height: 55.h,
                  child: ElevatedButton.icon(
                    onPressed: () {}, // Logically trigger dialer
                    icon: Icon(Icons.call_outlined, size: 20.sp),
                    label: Text(
                      'CALL NOW',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 14.sp,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRose,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
