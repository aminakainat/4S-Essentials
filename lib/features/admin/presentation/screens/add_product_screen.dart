import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_4sessentials/core/theme.dart';
import 'package:flutter_4sessentials/core/services/firestore_service.dart';
import 'package:flutter_4sessentials/core/services/storage_service.dart';

class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? productToEdit;
  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  
  String _selectedCategory = 'Rings';
  XFile? _pickedImage;
  String? _existingImageUrl;
  bool _isLoading = false;

  final List<String> _categories = [
    'Rings',
    'Bangles',
    'Earrings',
    'Necklace',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      final p = widget.productToEdit!;
      _nameController.text = p['name'] ?? '';
      _priceController.text = (p['price'] ?? '').toString().replaceAll('\$', '').replaceAll(',', '');
      _descriptionController.text = p['description'] ?? '';
      _stockController.text = (p['stock'] ?? '0').toString();
      _selectedCategory = p['category'] ?? 'Rings';
      _existingImageUrl = p['image'];
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImage == null && _existingImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product image'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String imageUrl = _existingImageUrl ?? '';

      // Upload new image if picked with timeout and fallback
      if (_pickedImage != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_nameController.text.trim().replaceAll(' ', '_')}.jpg';
        try {
          imageUrl = await StorageService()
              .uploadProductImage(_pickedImage!, fileName)
              .timeout(const Duration(seconds: 5));
        } catch (e) {
          debugPrint('Storage upload timed out/failed. Falling back to category default image. Error: $e');
          // Fallback image URLs depending on the category selected
          if (_selectedCategory == 'Rings') {
            imageUrl = 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=800&q=80';
          } else if (_selectedCategory == 'Bangles') {
            imageUrl = 'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?auto=format&fit=crop&w=800&q=80';
          } else if (_selectedCategory == 'Earrings') {
            imageUrl = 'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=800&q=80';
          } else {
            imageUrl = 'https://images.pexels.com/photos/10983783/pexels-photo-10983783.jpeg?auto=compress&cs=tinysrgb&w=800';
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Using high-quality preset image due to network/storage connection speed.'),
                backgroundColor: Colors.orangeAccent,
              ),
            );
          }
        }
      }

      final productData = {
        'name': _nameController.text.trim(),
        'price': '\$${double.parse(_priceController.text.trim()).toStringAsFixed(2)}',
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'stock': int.parse(_stockController.text.trim()),
        'image': imageUrl,
      };

      if (widget.productToEdit != null) {
        // Edit mode: update existing doc
        final productId = widget.productToEdit!['productId'];
        await FirestoreService().updateProduct(productId, productData);
        if (mounted) {
          setState(() => _isLoading = false);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              title: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10.w),
                  Text('Product Updated', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D))),
                ],
              ),
              content: Text('Product "${productData['name']}" has been updated successfully.', style: GoogleFonts.outfit(color: Colors.grey.shade600)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Go back
                  },
                  child: Text('OK', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFFB9937E))),
                ),
              ],
            ),
          );
        }
      } else {
        // Add mode: create new doc
        await FirestoreService().addProduct(productData);
        if (mounted) {
          setState(() => _isLoading = false);
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              title: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 10.w),
                  Text('Product Added', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D))),
                ],
              ),
              content: Text('Product "${productData['name']}" has been added successfully and is now visible to customers.', style: GoogleFonts.outfit(color: Colors.grey.shade600)),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Go back
                  },
                  child: Text('OK', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFFB9937E))),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
        );
      }
    }
  } // end _saveProduct

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Widget _buildProductImage() {
    if (_pickedImage != null) {
      if (kIsWeb) {
        return Image.network(_pickedImage!.path, fit: BoxFit.cover);
      } else {
        return Image.file(File(_pickedImage!.path), fit: BoxFit.cover);
      }
    }
    if (_existingImageUrl != null) {
      return Image.network(_existingImageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined, size: 40.sp, color: const Color(0xFFB9937E)),
        SizedBox(height: 8.h),
        Text('Upload Image', style: GoogleFonts.outfit(fontSize: 12.sp, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productToEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F7),
      appBar: AppBar(
        title: Text(
          isEdit ? 'EDIT PRODUCT' : 'ADD PRODUCT',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 18.sp),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D2D2D)),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Selection Card
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 140.w,
                        height: 140.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25.r),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10.r, offset: const Offset(0, 5))
                          ],
                          border: Border.all(color: Colors.grey.shade200, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(23.r),
                          child: _buildProductImage(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 35.h),

                  // Fields
                  _buildLabel('Product Name'),
                  TextFormField(
                    controller: _nameController,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Please enter name' : null,
                    decoration: _buildInputDecoration('Enter product title'),
                  ),
                  SizedBox(height: 20.h),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Price (\$)'),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid price' : null,
                              decoration: _buildInputDecoration('Price'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Stock Quantity'),
                            TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid stock' : null,
                              decoration: _buildInputDecoration('Quantity'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel('Category'),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFB9937E)),
                        items: _categories.map((c) {
                          return DropdownMenuItem<String>(
                            value: c,
                            child: Text(c, style: GoogleFonts.outfit(color: const Color(0xFF2D2D2D), fontWeight: FontWeight.w500)),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              _selectedCategory = v;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  _buildLabel('Description'),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Please enter description' : null,
                    decoration: _buildInputDecoration('Write a description of the jewellery item...'),
                  ),
                  SizedBox(height: 40.h),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB9937E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                      ),
                      child: Text(
                        isEdit ? 'SAVE CHANGES' : 'CREATE PRODUCT',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 16.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFB9937E)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 5.w, bottom: 8.h),
      child: Text(
        text,
        style: GoogleFonts.outfit(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D)),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 14.sp),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.r), borderSide: BorderSide.none),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
    );
  }
}
