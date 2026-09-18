import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_4sessentials/features/auth/presentation/screens/signup_screen.dart';
import 'package:flutter_4sessentials/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:flutter_4sessentials/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_4sessentials/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:flutter_4sessentials/core/theme.dart';
import 'package:flutter_4sessentials/core/services/auth_service.dart';
import 'package:flutter_4sessentials/core/services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService().signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw 'Auth login timed out. Please check your network connection.';
      });

      if (user != null) {
        // Fetch user profile from Firestore to check role
        final doc = await FirestoreService().getUserProfile(user.uid).timeout(const Duration(seconds: 10), onTimeout: () {
          throw 'Firestore database read timed out. Please check your connection.';
        });
        String role = 'customer';
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          role = data?['role'] ?? 'customer';
        } else {
          // If no doc exists, create one with customer role
          await FirestoreService().saveUserProfile(user.uid, {
            'name': user.displayName ?? user.email?.split('@').first ?? 'User',
            'email': user.email ?? email,
            'role': 'customer',
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          }).timeout(const Duration(seconds: 10), onTimeout: () {
            throw 'Firestore database write timed out. Please check your connection.';
          });
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${user.displayName ?? "User"}! ($role)'),
            backgroundColor: Colors.green,
          ),
        );

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminPanelScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  FadeInDown(
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(15.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryRose.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          Icons.diamond_outlined,
                          size: 40.sp,
                          color: AppTheme.primaryRose,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50.h),
                  FadeInLeft(
                    child: Text(
                      'Welcome Back',
                      style: GoogleFonts.outfit(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                  ),
            FadeInLeft(
              delay: const Duration(milliseconds: 100),
              child: Text(
                'Login to access your premium collection',
                style: GoogleFonts.outfit(
                  color: Colors.grey.shade500,
                  fontSize: 15.sp,
                ),
              ),
            ),
            SizedBox(height: 40.h),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
            ),
            SizedBox(height: 15.h),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                child: Text('Forgot Password?', style: GoogleFonts.outfit(color: const Color(0xFFB9937E), fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: 30.h),
            Center(
              child: SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB9937E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('LOG IN', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16.sp)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeIn(
              delay: const Duration(milliseconds: 500),
              child: Center(
                child: Text('Or login with', style: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialBtn(Icons.g_mobiledata),
                  const SizedBox(width: 20),
                  _socialBtn(Icons.apple),
                ],
              ),
            ),
            const SizedBox(height: 40),
            FadeIn(
              delay: const Duration(milliseconds: 700),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account?', style: GoogleFonts.outfit(color: Colors.grey.shade500)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                    child: Text('SIGN UP', style: GoogleFonts.outfit(color: AppTheme.primaryRose, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FadeIn(
              delay: const Duration(milliseconds: 800),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Text(
                    'Tip: Create an Admin account via Sign Up to access the inventory dashboard.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      color: Colors.grey.shade400,
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),
    );
  }

  Widget _socialBtn(IconData icon) {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8.r,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          size: 22.sp,
          color: const Color(0xFF2D2D2D),
        ),
      ),
    );
  }
}

