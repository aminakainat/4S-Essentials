import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_4sessentials/core/theme.dart';

class CustomOrderScreen extends StatefulWidget {
  const CustomOrderScreen({super.key});

  @override
  State<CustomOrderScreen> createState() => _CustomOrderScreenState();
}

class _CustomOrderScreenState extends State<CustomOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedMetal = 'Gold (22K)';
  String _selectedStone = 'Diamond';
  String _selectedSize = 'M (6)';
  final _descriptionController = TextEditingController();
  XFile? _sketchImage;
  bool _isSubmitting = false;

  final List<String> _metals = ['Gold (24K)', 'Gold (22K)', 'Gold (18K)', 'Silver (925)', 'Platinum'];
  final List<String> _stones = ['None', 'Diamond', 'Ruby', 'Emerald', 'Sapphire', 'Pearl'];
  final List<String> _sizes = ['S (5)', 'M (6)', 'L (7)', 'XL (8)', 'Custom (Enter details)'];

  void _pickSketch() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        _sketchImage = img;
      });
    }
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a custom order'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'userId': user.uid,
        'userName': user.displayName ?? user.email?.split('@').first ?? 'Customer',
        'metalType': _selectedMetal,
        'stoneType': _selectedStone,
        'size': _selectedSize,
        'description': _descriptionController.text.trim(),
        'sketchImage': _sketchImage != null ? _sketchImage!.path : '', // mock upload path
        'status': 'Pending Review',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('custom_orders').add(data);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit order: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Center(
          child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 50.sp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Request Submitted!',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18.sp, color: context.textColor),
            ),
            SizedBox(height: 10.h),
            Text(
              'Our master jewelers will review your sketch and design details. You will receive an update in 24-48 hours.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 13.sp),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit screen
            },
            child: Text(
              'OK',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryRose),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'CUSTOM JEWELRY ORDER',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15.sp, color: context.textColor, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: context.textColor),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Design Your Masterpiece',
                style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.bold, color: context.textColor),
              ),
              SizedBox(height: 5.h),
              Text(
                'Specify materials, dimensions, and upload sketches to collaborate directly with our master craftsmen.',
                style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp, height: 1.4),
              ),
              SizedBox(height: 25.h),

              // Metal Selection
              _buildDropdownSection('Metal Base', _selectedMetal, _metals, (val) {
                if (val != null) setState(() => _selectedMetal = val);
              }),
              SizedBox(height: 20.h),

              // Gemstone Selection
              _buildDropdownSection('Gemstone Options', _selectedStone, _stones, (val) {
                if (val != null) setState(() => _selectedStone = val);
              }),
              SizedBox(height: 20.h),

              // Size selection
              _buildDropdownSection('Sizing Guide / Choice', _selectedSize, _sizes, (val) {
                if (val != null) setState(() => _selectedSize = val);
              }),
              SizedBox(height: 20.h),

              // Design description
              Text(
                'Describe Your Design',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.sp, color: context.textColor),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                style: GoogleFonts.outfit(color: context.textColor),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please describe your request' : null,
                decoration: InputDecoration(
                  hintText: 'Share design patterns, engraving requests, or finish details...',
                  hintStyle: GoogleFonts.outfit(color: context.subtextColor, fontSize: 13.sp),
                ),
              ),
              SizedBox(height: 25.h),

              // Upload Sketch Option
              Text(
                'Upload Sketch / Inspiration Picture',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.sp, color: context.textColor),
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: _pickSketch,
                child: Container(
                  width: double.infinity,
                  height: 150.h,
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: _sketchImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: kIsWeb
                              ? Image.network(_sketchImage!.path, fit: BoxFit.cover)
                              : Image.file(File(_sketchImage!.path), fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, color: AppTheme.primaryRose, size: 40.sp),
                            SizedBox(height: 8.h),
                            Text(
                              'Click to choose photo from gallery',
                              style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 40.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 55.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRose,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'SUBMIT CUSTOM ORDER',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.sp),
                        ),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection(
    String title,
    String currentValue,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.sp, color: context.textColor),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentValue,
              items: items.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: GoogleFonts.outfit(color: context.textColor)),
                );
              }).toList(),
              onChanged: onChanged,
              isExpanded: true,
              dropdownColor: context.surfaceColor,
              icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryRose, size: 24.sp),
            ),
          ),
        ),
      ],
    );
  }
}
