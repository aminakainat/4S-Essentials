import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_4sessentials/core/theme.dart';
import 'package:flutter_4sessentials/features/cart/data/cart_service.dart';
import 'package:flutter_4sessentials/core/services/recently_viewed_manager.dart';
import 'package:flutter_4sessentials/core/services/firestore_service.dart';
import 'package:flutter_4sessentials/features/home/presentation/screens/try_on_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String _selectedSize = 'M';
  int _quantity = 1;
  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];
  final List<Color> _colors = [
    const Color(0xFFC0C0C0), 
    const Color(0xFFD4AF37), 
    const Color(0xFFE5D1C5), 
  ];

  final _reviewTextController = TextEditingController();
  double _reviewRating = 5.0;

  @override
  void initState() {
    super.initState();
    RecentlyViewedManager.addProduct(widget.product);
  }

  @override
  void dispose() {
    _reviewTextController.dispose();
    super.dispose();
  }

  void _showPurityCertificate() {
    final certificate = widget.product['purityCertificate'] as Map<String, dynamic>? ?? {
      'karat': '22K Hallmarked Gold',
      'weight': '4.5 grams',
      'clarity': 'VVS1',
      'serialNumber': 'GIA-8829-2910-3882',
    };

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 30.h),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(45.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10.r))),
            SizedBox(height: 25.h),
            Icon(Icons.verified_user_rounded, color: const Color(0xFFD4AF37), size: 55.sp),
            SizedBox(height: 15.h),
            Text(
              'PURITY & AUTHENTICITY CERTIFICATE',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15.sp, color: const Color(0xFFD4AF37), letterSpacing: 1.2),
            ),
            SizedBox(height: 8.h),
            Text('Official laboratory testing results for this design.', style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp)),
            SizedBox(height: 25.h),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: context.scaffoldBg,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  _certRow('Metal Karat', certificate['karat']),
                  _certRow('Gross Weight', certificate['weight']),
                  _certRow('Diamond Clarity', certificate['clarity']),
                  _certRow('Certified Lab', 'IGI / GIA Certified'),
                  const Divider(color: Colors.grey),
                  _certRow('Serial Verification', certificate['serialNumber'], isBold: true),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
                child: Text('Close Certificate', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _certRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 13.sp)),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: context.textColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _showRingSizeGuide() {
    final sizeController = TextEditingController();
    String recommendedSize = 'Enter circumference below';

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
              borderRadius: BorderRadius.vertical(top: Radius.circular(45.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RING SIZE GUIDE',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp, color: context.textColor, letterSpacing: 1.2),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Measure your finger circumference in millimeters (mm) and calculate your corresponding size below.',
                  style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp, height: 1.4),
                ),
                SizedBox(height: 20.h),
                // Size Table
                Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(color: context.scaffoldBg, borderRadius: BorderRadius.circular(15.r)),
                  child: Column(
                    children: [
                      _sizeTableRow('Circumference (mm)', 'US Size'),
                      const Divider(),
                      _sizeTableRow('49.3 mm', 'Size 5 (S)'),
                      _sizeTableRow('51.8 mm', 'Size 6 (M)'),
                      _sizeTableRow('54.4 mm', 'Size 7 (L)'),
                      _sizeTableRow('56.9 mm', 'Size 8 (XL)'),
                      _sizeTableRow('59.5 mm', 'Size 9 (XXL)'),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Circumference Calculator',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.sp, color: context.textColor),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sizeController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.outfit(color: context.textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter mm (e.g. 54.4)',
                          hintStyle: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    ElevatedButton(
                      onPressed: () {
                        final val = double.tryParse(sizeController.text.trim()) ?? 0.0;
                        setModalState(() {
                          if (val <= 0) {
                            recommendedSize = 'Please enter a valid number';
                          } else if (val <= 49.3) {
                            recommendedSize = 'Size 5 (Small)';
                          } else if (val <= 51.8) {
                            recommendedSize = 'Size 6 (Medium)';
                          } else if (val <= 54.4) {
                            recommendedSize = 'Size 7 (Large)';
                          } else if (val <= 56.9) {
                            recommendedSize = 'Size 8 (Extra Large)';
                          } else {
                            recommendedSize = 'Size 9 (Double Extra Large)';
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
                      child: Text('Calculate', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Center(
                  child: Text(
                    'Recommended: $recommendedSize',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryRose, fontSize: 14.sp),
                  ),
                ),
                SizedBox(height: 25.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sizeTableRow(String col1, String col2) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(col1, style: GoogleFonts.outfit(color: context.textColor, fontSize: 12.sp)),
          Text(col2, style: GoogleFonts.outfit(color: context.textColor, fontWeight: FontWeight.bold, fontSize: 12.sp)),
        ],
      ),
    );
  }

  void _showAddReviewSheet() {
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(45.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Write a Product Review',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18.sp, color: context.textColor),
                ),
                SizedBox(height: 15.h),
                // Star Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isSelected = index < _reviewRating;
                    return IconButton(
                      onPressed: () {
                        setModalState(() {
                          _reviewRating = (index + 1).toDouble();
                        });
                      },
                      icon: Icon(
                        isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 36.sp,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 15.h),
                TextField(
                  controller: _reviewTextController,
                  maxLines: 3,
                  style: GoogleFonts.outfit(color: context.textColor),
                  decoration: InputDecoration(
                    hintText: 'Share your feedback about dynamic packaging, design details, metal luster...',
                    hintStyle: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp),
                  ),
                ),
                SizedBox(height: 25.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () async {
                      final comment = _reviewTextController.text.trim();
                      if (comment.isEmpty) return;
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log in to review!')));
                        return;
                      }

                      try {
                        await FirebaseFirestore.instance
                            .collection('products')
                            .doc(widget.product['productId'])
                            .collection('reviews')
                            .add({
                          'userId': user.uid,
                          'userName': user.displayName ?? user.email?.split('@').first ?? 'Customer',
                          'rating': _reviewRating,
                          'comment': comment,
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                        _reviewTextController.clear();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Review posted! Thank you.'), backgroundColor: Colors.green),
                          );
                        }
                      } catch (e) {
                        debugPrint('Review upload failed: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
                    child: Text('Submit Review', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
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
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 0.5.sh,
            child: Hero(
              tag: widget.product['productId'],
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.product['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 50),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularBtn(
                  Icons.arrow_back_ios_new,
                  onTap: () => Navigator.pop(context),
                ),
                _buildCircularBtn(
                  Icons.camera_alt_outlined,
                  iconColor: AppTheme.primaryRose,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TryOnScreen(product: widget.product)),
                    );
                  },
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 0.55.sh,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: context.isDarkMode ? 0.3 : 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeInUp(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.product['name'],
                                        style: GoogleFonts.outfit(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.bold,
                                          color: context.textColor,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      GestureDetector(
                                        onTap: _showAddReviewSheet,
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius: BorderRadius.circular(8.r),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.star_rounded, color: Colors.amber, size: 14.sp),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    '4.8 (Write Review)',
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.green.shade700,
                                                      fontSize: 11.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  widget.product['price'],
                                  style: GoogleFonts.outfit(
                                    fontSize: 20.sp,
                                    color: AppTheme.primaryRose,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          FadeInUp(
                            delay: const Duration(milliseconds: 100),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _showPurityCertificate,
                                    icon: const Icon(Icons.verified, color: Color(0xFFD4AF37)),
                                    label: Text('Certificate', style: GoogleFonts.outfit(color: context.textColor, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFD4AF37))),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _showRingSizeGuide,
                                    icon: Icon(Icons.straighten, color: AppTheme.primaryRose),
                                    label: Text('Size Finder', style: GoogleFonts.outfit(color: context.textColor, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(side: BorderSide(color: AppTheme.primaryRose)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          FadeInUp(
                            delay: const Duration(milliseconds: 150),
                            child: Row(
                              children: [
                                Expanded(child: _buildChoiceSection('Material', _buildColorPicker())),
                                SizedBox(width: 20.w),
                                Expanded(child: _buildChoiceSection('Size', _buildSizePicker())),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description',
                                  style: GoogleFonts.outfit(
                                    color: context.textColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  widget.product['description'] ?? 'Crafted with precision and elegance, this piece embodies timeless luxury.',
                                  style: GoogleFonts.outfit(
                                    color: context.subtextColor,
                                    fontSize: 13.sp,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 25.h),

                          // Product Reviews List Section
                          Text('Customer Reviews', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp, color: context.textColor)),
                          SizedBox(height: 10.h),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('products')
                                .doc(widget.product['productId'])
                                .collection('reviews')
                                .orderBy('timestamp', descending: true)
                                .snapshots(),
                            builder: (context, rSnap) {
                              final reviews = rSnap.data?.docs ?? [];
                              if (reviews.isEmpty) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: Text('No reviews yet. Be the first to share!', style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp)),
                                );
                              }
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reviews.length,
                                itemBuilder: (context, rIdx) {
                                  final rData = reviews[rIdx].data() as Map<String, dynamic>;
                                  final rName = rData['userName'] ?? 'Customer';
                                  final rStars = (rData['rating'] as num? ?? 5).toInt();
                                  final rComment = rData['comment'] ?? '';

                                  return Container(
                                    margin: EdgeInsets.only(bottom: 10.h),
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(color: context.scaffoldBg, borderRadius: BorderRadius.circular(15.r)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(rName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12.sp, color: context.textColor)),
                                            Row(
                                              children: List.generate(5, (sIdx) {
                                                return Icon(
                                                  sIdx < rStars ? Icons.star : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: 12.sp,
                                                );
                                              }),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 6.h),
                                        Text(rComment, style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp)),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          SizedBox(height: 25.h),

                          // recommendations section "You May Also Like"
                          Text('You May Also Like', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp, color: context.textColor)),
                          SizedBox(height: 10.h),
                          SizedBox(
                            height: 160.h,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirestoreService().getProductsByCategoryStream(widget.product['category'] ?? 'Rings'),
                              builder: (context, snapshot) {
                                final all = snapshot.data?.docs ?? [];
                                final filtered = all.where((d) => d.id != widget.product['productId']).map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
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

                                if (filtered.isEmpty) {
                                  return Center(child: Text('No other items found', style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp)));
                                }

                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: filtered.length,
                                  itemBuilder: (context, fIdx) {
                                    final item = filtered[fIdx];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: item)),
                                        );
                                      },
                                      child: Container(
                                        width: 110.w,
                                        margin: EdgeInsets.only(right: 15.w),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(15.r),
                                              child: Image.network(item['image'], width: 110.w, height: 95.h, fit: BoxFit.cover),
                                            ),
                                            SizedBox(height: 6.h),
                                            Text(item['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12.sp, color: context.textColor)),
                                            Text(item['price'], style: GoogleFonts.outfit(color: AppTheme.primaryRose, fontWeight: FontWeight.bold, fontSize: 11.sp)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Container(
                        height: 55.h,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: context.scaffoldBg,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Row(
                          children: [
                            _qtyBtn(Icons.remove, () {
                              if (_quantity > 1) setState(() => _quantity--);
                            }),
                            SizedBox(width: 15.w),
                            Text(
                              '$_quantity',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp, color: context.textColor),
                            ),
                            SizedBox(width: 15.w),
                            _qtyBtn(Icons.add, () => setState(() => _quantity++)),
                          ],
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Expanded(
                        child: SizedBox(
                          height: 55.h,
                          child: ElevatedButton(
                            onPressed: () {
                              CartService().addItem(widget.product, _quantity);
                              _showSuccessSheet(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryRose,
                              foregroundColor: Colors.white,
                              shadowColor: AppTheme.primaryRose.withValues(alpha: 0.4),
                              elevation: 8,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                            ),
                            child: Text(
                              'Add To Cart',
                              style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(25.w, 20.h, 25.w, 30.h),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10.r)),
              ),
              SizedBox(height: 25.h),
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 50.sp),
              SizedBox(height: 15.h),
              Text('Success!', style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold, color: context.textColor)),
              SizedBox(height: 8.h),
              Text('Item added to your cart successfully', textAlign: TextAlign.center, style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp)),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                        side: BorderSide(color: AppTheme.primaryRose),
                      ),
                      child: Text('Continue', style: GoogleFonts.outfit(color: AppTheme.primaryRose, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                      ),
                      child: Text('Ok', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularBtn(IconData icon, {Color? iconColor, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Icon(icon, size: 18.sp, color: iconColor ?? context.textColor),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(color: context.surfaceColor, shape: BoxShape.circle),
        child: Icon(icon, size: 14.sp, color: context.textColor),
      ),
    );
  }

  Widget _buildChoiceSection(String title, Widget picker) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 12.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 10.h),
        picker,
      ],
    );
  }

  Widget _buildColorPicker() {
    return Row(
      children: _colors.map((color) {
        return Container(
          margin: EdgeInsets.only(right: 8.w),
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.w),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4.r)],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizePicker() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _sizes.map((size) {
          bool isSelected = _selectedSize == size;
          return GestureDetector(
            onTap: () => setState(() => _selectedSize = size),
            child: Container(
              margin: EdgeInsets.only(right: 6.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryRose : context.surfaceColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: isSelected ? Colors.transparent : context.borderColor),
              ),
              child: Text(
                size,
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.white : context.textColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
