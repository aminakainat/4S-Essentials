import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_4sessentials/core/theme.dart';
import 'package:flutter_4sessentials/core/services/firestore_service.dart';
import 'package:flutter_4sessentials/features/home/presentation/screens/product_details_screen.dart';

class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  XFile? _image;
  bool _isScanning = false;
  bool _scanComplete = false;
  List<Map<String, dynamic>> _matchedProducts = [];

  void _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: source);
    if (img != null) {
      setState(() {
        _image = img;
        _isScanning = true;
        _scanComplete = false;
        _matchedProducts.clear();
      });

      // Simulate AI Scanning Animation
      Future.delayed(const Duration(seconds: 3), () async {
        if (!mounted) return;

        // Fetch products from Firestore to find matches
        try {
          final query = await FirebaseFirestore.instance.collection('products').get();
          final all = query.docs.map((doc) {
            final data = doc.data();
            return {
              'productId': doc.id,
              'name': data['name'] ?? '',
              'price': data['price'] ?? '',
              'image': data['image'] ?? '',
              'category': data['category'] ?? '',
              'description': data['description'] ?? '',
              'stock': data['stock'] ?? 0,
            };
          }).toList();

          // Shuffle or select 2-3 random items to simulate image matching
          all.shuffle();
          setState(() {
            _matchedProducts = all.take(3).toList();
            _isScanning = false;
            _scanComplete = true;
          });
        } catch (e) {
          setState(() {
            _isScanning = false;
            _scanComplete = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'IMAGE SEARCH',
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
        child: Column(
          children: [
            // Image Preview Area
            Container(
              width: double.infinity,
              height: 250.h,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(color: context.borderColor),
              ),
              child: _image != null
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25.r),
                            child: kIsWeb
                                ? Image.network(_image!.path, fit: BoxFit.cover)
                                : Image.file(File(_image!.path), fit: BoxFit.cover),
                          ),
                        ),
                        if (_isScanning)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.3),
                              child: ZoomIn(
                                duration: const Duration(seconds: 2),
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 30.w, vertical: 60.h),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppTheme.primaryRose, width: 2.w),
                                    borderRadius: BorderRadius.circular(15.r),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_search_rounded, color: AppTheme.primaryRose, size: 60.sp),
                        SizedBox(height: 15.h),
                        Text(
                          'Upload a photo of any jewelry item',
                          style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 13.sp),
                        ),
                        Text(
                          'We will find matching designs in our store.',
                          style: GoogleFonts.outfit(color: context.subtextColor.withValues(alpha: 0.7), fontSize: 11.sp),
                        ),
                      ],
                    ),
            ),
            SizedBox(height: 25.h),

            // Image Source Selector
            if (!_isScanning) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: Text('Camera', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRose,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: Icon(Icons.photo_library, color: AppTheme.primaryRose),
                      label: Text('Gallery', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryRose)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                        side: BorderSide(color: AppTheme.primaryRose),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 35.h),
            ],

            if (_isScanning) ...[
              Text(
                'AI Scanning Visual Features...',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppTheme.primaryRose),
              ),
              SizedBox(height: 10.h),
              const CircularProgressIndicator(color: AppTheme.primaryRose),
              SizedBox(height: 40.h),
            ],

            // Matches List
            if (_scanComplete) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Similar Products Found (${_matchedProducts.length})',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp, color: context.textColor),
                ),
              ),
              SizedBox(height: 15.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _matchedProducts.length,
                itemBuilder: (context, index) {
                  final p = _matchedProducts[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 100),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: p)),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.01), blurRadius: 10)
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.network(p['image'], width: 70.w, height: 70.w, fit: BoxFit.cover),
                            ),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['name'],
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: context.textColor, fontSize: 14.sp),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    p['category'],
                                    style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    p['price'],
                                    style: GoogleFonts.outfit(color: AppTheme.primaryRose, fontWeight: FontWeight.bold, fontSize: 13.sp),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 14.sp, color: context.subtextColor.withValues(alpha: 0.3)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
