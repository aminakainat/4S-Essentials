import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_4sessentials/core/theme.dart';
import 'package:flutter_4sessentials/core/services/firestore_service.dart';
import 'package:flutter_4sessentials/features/home/presentation/screens/filter_screen.dart';
import 'package:flutter_4sessentials/features/home/presentation/screens/product_details_screen.dart';
import 'package:flutter_4sessentials/features/cart/presentation/screens/cart_screen.dart';
import 'package:flutter_4sessentials/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter_4sessentials/features/home/presentation/screens/custom_order_screen.dart';
import 'package:flutter_4sessentials/features/home/presentation/screens/ai_assistant_screen.dart';
import 'package:flutter_4sessentials/features/home/presentation/screens/image_search_screen.dart';
import 'package:flutter_4sessentials/core/services/recently_viewed_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  String _userName = 'amna';
  String _userPhone = '+880 1234 567 890';
  dynamic _userImage;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _seedDefaultProductsIfNeeded();
  }

  void _seedDefaultProductsIfNeeded() async {
    try {
      await FirestoreService().seedDefaultProducts(allProducts);
    } catch (e) {
      debugPrint('Failed to seed default products: $e');
    }
  }

  void _loadCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? user.email?.split('@').first ?? 'User';
      });
    }
  }

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Rings', 'icon': Icons.circle_outlined},
    {'name': 'Bangles', 'icon': Icons.gesture_outlined},
    {'name': 'Earrings', 'icon': Icons.earbuds_rounded},
    {'name': 'Necklace', 'icon': Icons.diamond_outlined},
  ];

  final List<Map<String, dynamic>> allProducts = [
    {
      'name': 'Small Gold Bangle',
      'price': '\$120.00',
      'image':
          'https://images.unsplash.com/photo-1611591437281-460bfbe1220a?auto=format&fit=crop&w=800&q=80',
      'category': 'Bangles',
    },
    {
      'name': 'Pearl Drop Earrings',
      'price': '\$2,500.00',
      'image':
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?auto=format&fit=crop&w=800&q=80',
      'category': 'Earrings',
    },
    {
      'name': 'Stainless Steel Ring',
      'price': '\$45.00',
      'image':
          'https://images.pexels.com/photos/1458867/pexels-photo-1458867.jpeg?auto=compress&cs=tinysrgb&w=800',
      'category': 'Rings',
    },
    {
      'name': 'Silver Studs',
      'price': '\$85.00',
      'image':
          'https://images.pexels.com/photos/2849743/pexels-photo-2849743.jpeg?auto=compress&cs=tinysrgb&w=800',
      'category': 'Earrings',
    },
    {
      'name': 'Diamond Band',
      'price': '\$850.00',
      'image':
          'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=800&q=80',
      'category': 'Rings',
    },
    {
      'name': 'Floral Necklace',
      'price': '\$3,200.00',
      'image':
          'https://images.pexels.com/photos/10983783/pexels-photo-10983783.jpeg?auto=compress&cs=tinysrgb&w=800',
      'category': 'Necklace',
    },
    {
      'name': 'Rose Gold Hoop',
      'price': '\$150.00',
      'image':
          'https://images.pexels.com/photos/1413420/pexels-photo-1413420.jpeg?auto=compress&cs=tinysrgb&w=800',
      'category': 'Earrings',
    },
  ];



  Widget _buildUserImage(BuildContext context) {
    if (_userImage == null) {
      return Icon(
        Icons.person_rounded,
        color: const Color(0xFFB9937E),
        size: 24.sp,
      );
    }
    if (kIsWeb) {
      final String path = _userImage is File ? _userImage.path : _userImage.toString();
      return Image.network(path, fit: BoxFit.cover);
    } else {
      final File file = _userImage is File ? _userImage as File : File(_userImage.toString());
      return Image.file(file, fit: BoxFit.cover);
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.outfit(
                        color: context.subtextColor,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _userName,
                      style: GoogleFonts.outfit(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 45.w,
                  height: 45.w,
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(15.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.01),
                        blurRadius: 10.r,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: _buildUserImage(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          
          // Search & Filters Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.02),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: GoogleFonts.outfit(color: context.textColor),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: GoogleFonts.outfit(
                          color: context.subtextColor,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: context.subtextColor,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // AI Image Search (Camera)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ImageSearchScreen()),
                  ),
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB9937E).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Icon(Icons.camera_alt_rounded, color: const Color(0xFFB9937E), size: 22.sp),
                  ),
                ),
                const SizedBox(width: 8),

                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FilterScreen(),
                    ),
                  ),
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB9937E),
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Icon(Icons.tune, color: Colors.white, size: 22.sp),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Custom Design Order Banner
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CustomOrderScreen()),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB9937E), Color(0xFFE5D1C5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFB9937E).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bespoke Custom Orders',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.white),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Design your signature jewelry piece with our master craftsmen.',
                            style: GoogleFonts.outfit(fontSize: 11.sp, color: Colors.white.withValues(alpha: 0.9), height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFFB9937E)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Category Selector
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected =
                    _selectedCategory == categories[index]['name'];
                return GestureDetector(
                  onTap: () => setState(
                    () => _selectedCategory = categories[index]['name'],
                  ),
                  child: Container(
                    margin: EdgeInsets.only(right: 15.w),
                    width: 75.w,
                    child: Column(
                      children: [
                        Container(
                          width: 55.w,
                          height: 55.w,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFB9937E)
                                : context.surfaceColor,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : context.borderColor,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.02),
                                blurRadius: 8.r,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: Icon(
                            categories[index]['icon'],
                            color: isSelected
                                ? Colors.white
                                : context.subtextColor,
                            size: 22.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          categories[index]['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: isSelected
                                ? const Color(0xFFB9937E)
                                : context.subtextColor,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Recently Viewed Products Section
          ValueListenableBuilder<int>(
            valueListenable: RecentlyViewedManager.changeNotifier,
            builder: (context, _v, _) {
              final items = RecentlyViewedManager.items;
              if (items.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.w),
                    child: Text(
                      'Recently Viewed',
                      style: GoogleFonts.outfit(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 150.h,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 25.w),
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: item)),
                          ),
                          child: Container(
                            width: 110.w,
                            margin: EdgeInsets.only(right: 15.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15.r),
                                  child: Image.network(item['image']!, width: 110.w, height: 90.h, fit: BoxFit.cover),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  item['name']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: context.textColor, fontSize: 12.sp),
                                ),
                                Text(
                                  item['price']!,
                                  style: GoogleFonts.outfit(color: AppTheme.primaryRose, fontWeight: FontWeight.bold, fontSize: 11.sp),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 15.h),
                ],
              );
            },
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Text(
              _selectedCategory == 'All'
                  ? 'New Arrivals'
                  : 'Best of $_selectedCategory',
              style: GoogleFonts.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
          ),
          const SizedBox(height: 15),
          StreamBuilder<QuerySnapshot>(
            stream: FirestoreService().getProductsByCategoryStream(_selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Text('Error loading products', style: GoogleFonts.outfit(color: Colors.redAccent)),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFB9937E)));
              }

              final docs = snapshot.data?.docs ?? [];
              final filteredProducts = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  'productId': data['productId'] ?? doc.id,
                  'name': data['name'] ?? '',
                  'price': data['price'] ?? '',
                  'image': data['image'] ?? '',
                  'category': data['category'] ?? '',
                  'description': data['description'] ?? '',
                  'stock': data['stock'] ?? 0,
                  'createdAt': data['createdAt'],
                };
              }).where((p) {
                final name = p['name'].toString().toLowerCase();
                return name.contains(_searchQuery.toLowerCase());
              }).toList();

              // Sort by createdAt descending in memory
              filteredProducts.sort((a, b) {
                final aTime = a['createdAt'] as Timestamp?;
                final bTime = b['createdAt'] as Timestamp?;
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return -1; // Keep newly created product (null timestamp) at the top
                if (bTime == null) return 1;
                return bTime.compareTo(aTime);
              });

              if (filteredProducts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(50),
                    child: Text(
                      'No products found',
                      style: GoogleFonts.outfit(color: context.subtextColor),
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 15.w,
                  mainAxisSpacing: 15.h,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return FadeInUp(
                    key: ValueKey('${product['productId']}_$_selectedCategory'),
                    delay: Duration(milliseconds: 100 * index),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailsScreen(product: product),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(25.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.02),
                              blurRadius: 10.r,
                              offset: Offset(0, 5.h),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Hero(
                                tag: product['productId']!,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(25.r),
                                  ),
                                  child: Image.network(
                                    product['image']!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => Container(
                                          color: context.scaffoldBg,
                                          child: const Icon(
                                            Icons
                                                .image_not_supported_outlined,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(15.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14.sp,
                                      color: context.textColor,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        product['price']!,
                                        style: GoogleFonts.outfit(
                                          color: const Color(0xFFB9937E),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                      Icon(
                                        Icons.add_circle,
                                        color: const Color(0xFFB9937E),
                                        size: 18.sp,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(),
      const CartScreen(),

      ProfileScreen(
        userName: _userName,
        userPhone: _userPhone,
        userImage: _userImage,
        onUpdate: (newName, newPhone, newImage) {
          setState(() {
            _userName = newName;
            _userPhone = newPhone;
            _userImage = newImage;
          });
        },
      ),
    ];

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(child: pages[_currentIndex]),
      floatingActionButton: _currentIndex == 1
          ? null
          : FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIAssistantScreen()),
              ),
              backgroundColor: AppTheme.primaryRose,
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
              child: Icon(Icons.psychology, color: Colors.white, size: 28.sp),
            ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.05),
              blurRadius: 10.r,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF966C55),
          unselectedItemColor: context.subtextColor.withValues(alpha: 0.75),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag_rounded),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
