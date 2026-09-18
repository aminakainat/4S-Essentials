import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_4sessentials/core/theme.dart';
import 'package:flutter_4sessentials/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_4sessentials/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_4sessentials/features/admin/presentation/screens/admin_panel_screen.dart';
import 'package:flutter_4sessentials/core/services/auth_service.dart';
import 'package:flutter_4sessentials/core/services/firestore_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'customer';
  bool _isLoading = false;

  void _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService()
          .signUpWithEmailAndPassword(
            email: email,
            password: password,
            name: name,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw 'Auth registration timed out. Please check your network connection.';
            },
          );

      if (user != null) {
        await Future.delayed(const Duration(milliseconds: 600));

        await FirestoreService()
            .saveUserProfile(user.uid, {
              'name': name,
              'email': email,
              'role': _selectedRole,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
            })
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw 'Firestore database profile creation timed out. Please check your connection.';
              },
            );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome, ${user.displayName ?? "User"}! Account created successfully as $_selectedRole.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        if (_selectedRole == 'admin') {
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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF3F3F7),
      body: SafeArea(
        child: Center(
          // SingleChildScrollView کو باہر لانے سے اسکرولنگ صحیح کام کرے گی
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // کالم کو صرف ضرورت جتنی جگہ لینے دیں
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryRose.withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          Icons.diamond_outlined,
                          size: 36.sp,
                          color: AppTheme.primaryRose,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Welcome!',
                      style: GoogleFonts.outfit(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                    Text(
                      'Let\'s get started with a free 4s Essentials account',
                      style: GoogleFonts.outfit(
                        color: Colors.grey.shade500,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 22.h),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Full Name',
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email Address',
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                        prefixIcon: const Icon(Icons.lock_outline),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFFB9937E),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'customer',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    color: Color(0xFFB9937E),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Register as Customer'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings_outlined,
                                    color: Color(0xFFB9937E),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Register as Admin'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedRole = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB9937E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  'SIGN UP',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    fontSize: 16.sp,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Center(
                      child: Text(
                        'Or sign up with',
                        style: GoogleFonts.outfit(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialBtn(Icons.g_mobiledata),
                        const SizedBox(width: 20),
                        _socialBtn(Icons.apple),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: GoogleFonts.outfit(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          ),
                          child: Text(
                            'LOG IN',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFB9937E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
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
        child: Icon(icon, size: 22.sp, color: const Color(0xFF2D2D2D)),
      ),
    );
  }
}
