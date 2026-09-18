import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_4sessentials/core/theme.dart';

class TryOnScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const TryOnScreen({super.key, required this.product});

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  XFile? _userImage;
  String _activeTemplate = 'Hand'; // Hand, Face, Neck
  double _scale = 1.0;
  double _previousScale = 1.0;
  double _rotation = 0.0;
  double _previousRotation = 0.0;
  Offset _offset = const Offset(150, 200);

  final List<String> _templates = ['Hand', 'Face', 'Neck'];

  final Map<String, String> _templateUrls = {
    'Hand': 'https://images.unsplash.com/photo-1573855619003-97b4799dcd8b?auto=format&fit=crop&w=800&q=80',
    'Face': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=800&q=80',
    'Neck': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
  };

  void _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _userImage = image;
        _activeTemplate = ''; // override template
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentCategory = widget.product['category'] ?? 'Rings';
    // Automatically match template if category matches
    String defaultTemp = 'Hand';
    if (currentCategory == 'Earrings' || currentCategory == 'Rings') {
      defaultTemp = currentCategory == 'Rings' ? 'Hand' : 'Face';
    } else if (currentCategory == 'Necklace') {
      defaultTemp = 'Neck';
    }

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'VIRTUAL TRY-ON',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp, color: context.textColor, letterSpacing: 1.2),
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
            onPressed: _pickImage,
            icon: Icon(Icons.camera_alt_outlined, color: AppTheme.primaryRose, size: 22.sp),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // 1. Background image (Template or Camera Image)
                Positioned.fill(
                  child: _userImage != null
                      ? (kIsWeb
                          ? Image.network(_userImage!.path, fit: BoxFit.cover)
                          : Image.file(File(_userImage!.path), fit: BoxFit.cover))
                      : Image.network(
                          _templateUrls[_activeTemplate.isEmpty ? defaultTemp : _activeTemplate]!,
                          fit: BoxFit.cover,
                        ),
                ),

                // Black overlay helper text
                Positioned(
                  top: 20.h,
                  left: 20.w,
                  right: 20.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Text(
                      'Drag, rotate, and pinch to size the jewelry item on your photo.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 11.sp),
                    ),
                  ),
                ),

                // 2. Interactive Overlaid Product Jewelry
                Positioned(
                  left: _offset.dx,
                  top: _offset.dy,
                  child: GestureDetector(
                    onScaleStart: (details) {
                      _previousScale = _scale;
                      _previousRotation = _rotation;
                    },
                    onScaleUpdate: (details) {
                      setState(() {
                        _scale = _previousScale * details.scale;
                        _rotation = _previousRotation + details.rotation;
                        _offset += details.focalPointDelta;
                      });
                    },
                    child: Transform.rotate(
                      angle: _rotation,
                      child: Transform.scale(
                        scale: _scale,
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Image.network(
                            widget.product['image'],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Control Panel
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Choose Template',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp, color: context.textColor),
                    ),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                      label: Text('Upload Image', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _templates.map((temp) {
                    final isSelected = _activeTemplate == temp;
                    return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _activeTemplate = temp;
                          _userImage = null; // reset camera image
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? AppTheme.primaryRose : context.scaffoldBg,
                        foregroundColor: isSelected ? Colors.white : context.textColor,
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                      child: Text(temp, style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),
                // Reset option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _scale = 1.0;
                          _rotation = 0.0;
                          _offset = const Offset(150, 200);
                        });
                      },
                      icon: Icon(Icons.refresh, color: AppTheme.primaryRose, size: 22.sp),
                    ),
                    Text('Reset Position', style: GoogleFonts.outfit(color: context.textColor, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
