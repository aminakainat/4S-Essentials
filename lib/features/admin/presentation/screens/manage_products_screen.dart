import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_4sessentials/core/theme.dart';
import 'package:flutter_4sessentials/core/services/firestore_service.dart';
import 'package:flutter_4sessentials/features/admin/presentation/screens/add_product_screen.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _confirmDelete(BuildContext context, String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Product', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF2D2D2D))),
        content: Text('Are you sure you want to delete "$productName"? This action cannot be undone.', style: GoogleFonts.outfit(color: Colors.grey.shade600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); 
              try {
                await FirestoreService().deleteProduct(productId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"$productName" deleted successfully'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: Text('DELETE', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F7),
      appBar: AppBar(
        title: Text(
          'MANAGE PRODUCTS',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen())),
        backgroundColor: const Color(0xFFB9937E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10.r, offset: const Offset(0, 4))
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search products by name...',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 14.sp),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFB9937E)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Real-time Product Stream List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getProductsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Text('Error: ${snapshot.error}', style: GoogleFonts.outfit(color: Colors.redAccent)),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFB9937E)));
                }

                final docs = snapshot.data?.docs ?? [];
                
                // Client side query filter
                final filteredDocs = docs.where((doc) {
                  final name = (doc.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 60.sp, color: Colors.grey.shade400),
                        SizedBox(height: 15.h),
                        Text(
                          _searchQuery.isEmpty ? 'No products found' : 'No matching results',
                          style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16.sp, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final productId = data['productId'] ?? doc.id;
                    final name = data['name'] ?? '';
                    final price = data['price'] ?? '';
                    final image = data['image'] ?? '';
                    final category = data['category'] ?? '';
                    final stock = data['stock'] ?? 0;

                    return FadeInUp(
                      delay: Duration(milliseconds: index * 50),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15.h),
                        padding: EdgeInsets.all(15.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10.r, offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          children: [
                            // Product Image
                            Container(
                              width: 70.w,
                              height: 70.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F7),
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15.r),
                                child: image.isNotEmpty
                                    ? Image.network(image, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_outlined))
                                    : const Icon(Icons.image_outlined),
                              ),
                            ),
                            SizedBox(width: 15.w),

                            // Product details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15.sp, color: const Color(0xFF2D2D2D)),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Text(category, style: GoogleFonts.outfit(color: const Color(0xFFB9937E), fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                      SizedBox(width: 10.w),
                                      Text('|', style: TextStyle(color: Colors.grey.shade300)),
                                      SizedBox(width: 10.w),
                                      Text('Stock: $stock', style: GoogleFonts.outfit(color: stock > 0 ? Colors.grey : Colors.red, fontSize: 12.sp, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(price, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14.sp, color: const Color(0xFF2D2D2D))),
                                ],
                              ),
                            ),

                            // Actions
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit
                                IconButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AddProductScreen(productToEdit: data)),
                                  ),
                                  icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.all(8.w),
                                ),
                                // Delete
                                IconButton(
                                  onPressed: () => _confirmDelete(context, productId, name),
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.all(8.w),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
