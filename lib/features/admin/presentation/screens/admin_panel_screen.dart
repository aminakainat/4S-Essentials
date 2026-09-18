import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_4sessentials/core/theme.dart';
import 'package:flutter_4sessentials/core/services/firestore_service.dart';
import 'package:flutter_4sessentials/features/admin/presentation/screens/add_product_screen.dart';
import 'package:flutter_4sessentials/features/admin/presentation/screens/manage_products_screen.dart';
import 'package:flutter_4sessentials/features/admin/presentation/screens/coupon_management_screen.dart';
import 'package:flutter_4sessentials/features/admin/presentation/screens/live_chat_admin_screen.dart';
import 'package:flutter_4sessentials/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_4sessentials/core/services/auth_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final Map<String, TextEditingController> _stockControllers = {};

  @override
  void dispose() {
    for (var controller in _stockControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _changeOrderStatus(BuildContext context, String orderId, String currentStatus) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Order Status',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Select a new status for Order #${orderId.substring(0, 6).toUpperCase()}',
              style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 13.sp),
            ),
            const SizedBox(height: 20),
            _statusOption(context, orderId, 'Pending', Colors.orange, currentStatus == 'Pending'),
            _statusOption(context, orderId, 'Processing', Colors.purple, currentStatus == 'Processing'),
            _statusOption(context, orderId, 'Shipped', Colors.blue, currentStatus == 'Shipped'),
            _statusOption(context, orderId, 'Delivered', Colors.green, currentStatus == 'Delivered'),
            _statusOption(context, orderId, 'Cancelled', Colors.red, currentStatus == 'Cancelled'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _statusOption(BuildContext context, String orderId, String status, Color color, bool isSelected) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(Icons.circle, color: color, size: 12.sp),
      ),
      title: Text(
        status,
        style: GoogleFonts.outfit(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: context.textColor,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: color) : null,
      onTap: () async {
        Navigator.pop(context); // Close bottom sheet
        try {
          await FirestoreService().updateOrderStatus(orderId, status);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order status updated to $status'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error updating status: $e'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildRevenueChart(double totalRevenue) {
    return Container(
      height: 150.h,
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Over Time (\$)',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: context.textColor, fontSize: 13.sp),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: ClipRect(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 5,
                  minY: 0,
                  maxY: totalRevenue > 0 ? totalRevenue * 1.2 : 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: totalRevenue > 0
                          ? [
                              FlSpot(0, totalRevenue * 0.15),
                              FlSpot(1, totalRevenue * 0.35),
                              FlSpot(2, totalRevenue * 0.45),
                              FlSpot(3, totalRevenue * 0.7),
                              FlSpot(4, totalRevenue * 0.85),
                              FlSpot(5, totalRevenue),
                            ]
                          : [
                              const FlSpot(0, 0),
                              const FlSpot(1, 0),
                              const FlSpot(2, 0),
                              const FlSpot(3, 0),
                              const FlSpot(4, 0),
                              const FlSpot(5, 0),
                            ],
                      isCurved: true,
                      color: AppTheme.primaryRose,
                      barWidth: 3.w,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.primaryRose.withValues(alpha: 0.15),
                      ),
                    ),
                  ],
                ),
              ),
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
          'ADMIN PANEL',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: context.textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: context.textColor),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await AuthService().signOut();
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live stats calculations
            StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getProductsStream(),
              builder: (context, prodSnapshot) {
                final prodDocs = prodSnapshot.data?.docs ?? [];
                int totalStock = 0;
                for (var d in prodDocs) {
                  final data = d.data() as Map<String, dynamic>?;
                  totalStock += (data?['stock'] as num? ?? 0).toInt();
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirestoreService().getOrdersStream(),
                  builder: (context, orderSnapshot) {
                    final orderDocs = orderSnapshot.data?.docs ?? [];
                    final totalOrders = orderDocs.length;
                    
                    int pendingOrders = 0;
                    int cancelledOrders = 0;
                    double revenue = 0.0;
                    
                    for (var d in orderDocs) {
                      final data = d.data() as Map<String, dynamic>?;
                      final status = data?['status'] ?? 'Pending';
                      if (status == 'Pending') pendingOrders++;
                      if (status == 'Cancelled') cancelledOrders++;
                      
                      final priceStr = (data?['totalPrice'] ?? '0').toString().replaceAll('\$', '').replaceAll(',', '');
                      revenue += double.tryParse(priceStr) ?? 0.0;
                    }

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirestoreService().getUsersStream(),
                      builder: (context, userSnapshot) {
                        final totalUsers = userSnapshot.data?.docs.length ?? 0;

                        return Column(
                          children: [
                            FadeInDown(
                              child: Row(
                                children: [
                                  Expanded(child: _buildDashBoardCard('Total Orders', '$totalOrders', Icons.shopping_bag_outlined)),
                                  const SizedBox(width: 15),
                                  Expanded(child: _buildDashBoardCard('Stock (Units)', '$totalStock', Icons.inventory_2_outlined)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            FadeInDown(
                              delay: const Duration(milliseconds: 100),
                              child: Row(
                                children: [
                                  Expanded(child: _buildDashBoardCard('Pending Orders', '$pendingOrders', Icons.hourglass_empty, valueColor: Colors.orange)),
                                  const SizedBox(width: 15),
                                  Expanded(child: _buildDashBoardCard('Cancelled Orders', '$cancelledOrders', Icons.cancel_outlined, valueColor: Colors.red)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            FadeInDown(
                              delay: const Duration(milliseconds: 150),
                              child: Row(
                                children: [
                                  Expanded(child: _buildDashBoardCard('Revenue', '\$${revenue.toStringAsFixed(2)}', Icons.monetization_on_outlined)),
                                  const SizedBox(width: 15),
                                  Expanded(child: _buildDashBoardCard('Customers', '$totalUsers', Icons.people_outline)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            // FlChart Revenue visual
                            FadeInUp(
                              child: _buildRevenueChart(revenue),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),

            // Low Stock Warnings Alerts Section
            StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getProductsStream(),
              builder: (context, snapshot) {
                final prods = snapshot.data?.docs ?? [];
                final lowStockProds = prods.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final stock = (data['stock'] as num? ?? 0).toInt();
                  return stock <= 4;
                }).toList();

                if (lowStockProds.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInLeft(
                      child: Text(
                        'Low Stock Alerts',
                        style: GoogleFonts.outfit(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.redAccent),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: lowStockProds.length,
                      itemBuilder: (context, index) {
                        final doc = lowStockProds[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['name'] ?? '';
                        final stock = (data['stock'] as num? ?? 0).toInt();
                        final docId = doc.id;

                        // Create text controller if not exist
                        if (!_stockControllers.containsKey(docId)) {
                          _stockControllers[docId] = TextEditingController(text: '$stock');
                        }

                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: context.textColor, fontSize: 13.sp)),
                                    Text('Current Stock: $stock', style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Container(
                                width: 50.w,
                                height: 40.h,
                                margin: EdgeInsets.only(right: 10.w),
                                child: TextField(
                                  controller: _stockControllers[docId],
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.outfit(color: context.textColor, fontSize: 13.sp),
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    fillColor: context.scaffoldBg,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final textVal = _stockControllers[docId]?.text.trim() ?? '';
                                  final newVal = int.tryParse(textVal) ?? 0;
                                  try {
                                    await FirestoreService().updateProduct(docId, {'stock': newVal});
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inventory restocked!'), backgroundColor: Colors.green));
                                    }
                                  } catch (e) {
                                    debugPrint('Stock save error: $e');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                ),
                                child: Text('Update', style: GoogleFonts.outfit(fontSize: 11.sp, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                  ],
                );
              },
            ),

            // Quick Actions Panel
            FadeInLeft(
              child: Text(
                'Quick Actions',
                style: GoogleFonts.outfit(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
            ),
            const SizedBox(height: 15),

            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Column(
                children: [
                  _buildQuickActionRow(
                    Icons.inventory_2_outlined,
                    'Manage Products',
                    'Add, update, or delete products',
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageProductsScreen())),
                  ),
                  SizedBox(height: 12.h),
                  _buildQuickActionRow(
                    Icons.add_photo_alternate_outlined,
                    'Add Product',
                    'Upload a new jewellery item',
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen())),
                  ),
                  SizedBox(height: 12.h),
                  _buildQuickActionRow(
                    Icons.local_offer_outlined,
                    'Manage Coupons',
                    'Create and edit discount codes',
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CouponManagementScreen())),
                  ),
                  SizedBox(height: 12.h),
                  _buildQuickActionRow(
                    Icons.chat_bubble_outline_rounded,
                    'Customer Live Support',
                    'Direct chat connection with users',
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveChatAdminScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Recent Orders Section Title
            FadeInLeft(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Incoming Orders',
                    style: GoogleFonts.outfit(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Live Recent Orders List
            StreamBuilder<QuerySnapshot>(
              stream: FirestoreService().getOrdersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFB9937E)));
                }

                final orderDocs = snapshot.data?.docs ?? [];
                if (orderDocs.isEmpty) {
                  return FadeIn(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Text(
                          'No orders placed yet',
                          style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 14.sp),
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderDocs.length,
                  itemBuilder: (context, index) {
                    final doc = orderDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final userName = data['userName'] ?? 'Customer';
                    final totalPrice = data['totalPrice'] ?? '\$0.00';
                    final status = data['status'] ?? 'Pending';
                    final orderId = doc.id.substring(0, 6).toUpperCase();

                    return FadeInUp(
                      delay: Duration(milliseconds: index * 50),
                      child: InkWell(
                        onTap: () => _changeOrderStatus(context, doc.id, status),
                        borderRadius: BorderRadius.circular(20.r),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryRose.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  color: AppTheme.primaryRose,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: 15.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #$orderId',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                        color: context.textColor,
                                      ),
                                    ),
                                    Text(
                                      'Customer: $userName',
                                      style: GoogleFonts.outfit(
                                        color: context.subtextColor,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    totalPrice.toString(),
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.primaryRose,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildStatusWidget(status),
                                ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildDashBoardCard(String title, String value, IconData icon, {Color? valueColor}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryRose.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppTheme.primaryRose, size: 20.sp),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: valueColor ?? context.textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: context.subtextColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusWidget(String status) {
    Color color;
    switch (status) {
      case 'Delivered':
        color = Colors.green;
        break;
      case 'Shipped':
        color = Colors.blue;
        break;
      case 'Processing':
        color = Colors.purple;
        break;
      case 'Cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuickActionRow(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFFB9937E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFB9937E), size: 22.sp),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(fontSize: 15.sp, fontWeight: FontWeight.bold, color: context.textColor),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(fontSize: 12.sp, color: context.subtextColor),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: context.subtextColor.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
