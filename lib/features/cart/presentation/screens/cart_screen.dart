import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_4sessentials/core/theme.dart';
import 'package:flutter_4sessentials/features/cart/data/cart_service.dart';
import 'package:flutter_4sessentials/core/services/firestore_service.dart';
import 'package:flutter_4sessentials/core/services/pdf_invoice_service.dart';
import 'package:flutter_4sessentials/features/profile/presentation/screens/addresses_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _paymentMethod = 'COD';
  double _discount = 0.0;
  double _discountPercent = 0.0;
  bool _isPlacingOrder = false;
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _giftCardMessageController =
      TextEditingController();

  List<String> _addresses = [];
  String? _selectedAddress;
  bool _isLoadingAddresses = true;

  bool _useGiftPackaging = false;

  int _checkoutStep = 0;

  @override
  void initState() {
    super.initState();
    CartService().addListener(_onCartChanged);
    _loadAddresses();
  }

  @override
  void dispose() {
    CartService().removeListener(_onCartChanged);
    _couponController.dispose();
    _giftCardMessageController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  void _loadAddresses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirestoreService().getUserProfile(user.uid);
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final list = data?['addresses'] as List<dynamic>? ?? [];
        setState(() {
          _addresses = list.map((e) => e.toString()).toList();
          if (_addresses.isNotEmpty) {
            _selectedAddress = _addresses.first;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    } finally {
      setState(() => _isLoadingAddresses = false);
    }
  }

  void _verifyCoupon() async {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    try {
      final query = await FirebaseFirestore.instance
          .collection('coupons')
          .where('code', isEqualTo: code)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        final pct = (data['discountPercent'] as num? ?? 0.0).toDouble();
        setState(() {
          _discountPercent = pct / 100.0;
          _discount = CartService().subtotal * _discountPercent;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coupon Applied! $pct% Off'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (code == 'GOLD10') {
        setState(() {
          _discountPercent = 0.10;
          _discount = CartService().subtotal * _discountPercent;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Coupon Applied! 10% Off'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid or expired coupon'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error applying coupon: $e');
    }
  }

  void _processCheckout() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or add a delivery address first'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_paymentMethod == 'Card') {
      _showCardDialog();
    } else if (_paymentMethod == 'JazzCash' || _paymentMethod == 'EasyPaisa') {
      _showMobileWalletDialog();
    } else {
      _placeOrder();
    }
  }

  void _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isPlacingOrder = true);

    try {
      final subtotal = CartService().subtotal;
      double packagingFee = _useGiftPackaging ? 5.00 : 0.00;
      double total = subtotal - _discount + packagingFee;

      final items = CartService().items
          .map(
            (e) => {
              'name': e['name'],
              'price': '\$${e['price'].toString()}',
              'qty': e['qty'],
              'image': e['image'],
            },
          )
          .toList();

      final orderData = {
        'userId': user.uid,
        'userName':
            user.displayName ?? user.email?.split('@').first ?? 'Customer',
        'items': items,
        'totalPrice': '\$${total.toStringAsFixed(2)}',
        'paymentMethod': _paymentMethod,
        'shippingAddress': _selectedAddress,
        'useGiftPackaging': _useGiftPackaging,
        'giftCardMessage': _giftCardMessageController.text.trim(),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = FirebaseFirestore.instance.collection('orders').doc();
      await docRef.set(orderData);

      for (var item in CartService().items) {
        final name = item['name'] as String;
        final qty = item['qty'] as int;
        final qSnap = await FirebaseFirestore.instance
            .collection('products')
            .where('name', isEqualTo: name)
            .limit(1)
            .get();
        if (qSnap.docs.isNotEmpty) {
          final doc = qSnap.docs.first;
          final currentStock = (doc.data()['stock'] as num? ?? 0).toInt();
          await doc.reference.update({
            'stock': (currentStock - qty).clamp(0, 99999),
          });
        }
      }

      if (!mounted) return;
      _showOrderSuccessDialog(context, docRef.id, total, packagingFee);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  void _showMobileWalletDialog() {
    final phoneController = TextEditingController();
    final pinController = TextEditingController();
    bool isAskingPin = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 30.h),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pay with $_paymentMethod',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: context.textColor,
                  ),
                ),
                SizedBox(height: 15.h),
                if (!isAskingPin) ...[
                  Text(
                    'Enter your $_paymentMethod Mobile Account number',
                    style: GoogleFonts.outfit(
                      color: context.subtextColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.outfit(color: context.textColor),
                    decoration: InputDecoration(
                      hintText: 'e.g. 03001234567',
                      hintStyle: GoogleFonts.outfit(
                        color: context.subtextColor,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (phoneController.text.trim().length >= 10) {
                          setModalState(() {
                            isAskingPin = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRose,
                      ),
                      child: Text(
                        'PROCEED TO PAY',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Authorize Transaction',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: context.textColor,
                    ),
                  ),
                  Text(
                    'Enter your 4-digit MPIN to authorize the checkout.',
                    style: GoogleFonts.outfit(
                      color: context.subtextColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    style: GoogleFonts.outfit(color: context.textColor),
                    decoration: InputDecoration(
                      hintText: '• • • •',
                      hintStyle: GoogleFonts.outfit(
                        color: context.subtextColor,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (pinController.text.length == 4) {
                          Navigator.pop(context);
                          _placeOrder();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRose,
                      ),
                      child: Text(
                        'CONFIRM PAYMENT',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCardDialog() {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 30.h),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Credit / Debit Card Details',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: context.textColor,
                  ),
                ),
                SizedBox(height: 15.h),

                Container(
                  width: double.infinity,
                  height: 160.h,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E2E3A), Color(0xFF0F0F15)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.credit_card,
                            color: AppTheme.primaryRose,
                            size: 30.sp,
                          ),
                          Text(
                            'VIP PLATINUM',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        cardNumberController.text.isEmpty
                            ? '•••• •••• •••• ••••'
                            : cardNumberController.text,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18.sp,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CARDHOLDER',
                                style: GoogleFonts.outfit(
                                  color: Colors.grey,
                                  fontSize: 9.sp,
                                ),
                              ),
                              Text(
                                nameController.text.isEmpty
                                    ? 'NAME'
                                    : nameController.text.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'EXPIRES',
                                style: GoogleFonts.outfit(
                                  color: Colors.grey,
                                  fontSize: 9.sp,
                                ),
                              ),
                              Text(
                                expiryController.text.isEmpty
                                    ? 'MM/YY'
                                    : expiryController.text,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                TextField(
                  controller: cardNumberController,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setModalState(() {}),
                  style: GoogleFonts.outfit(color: context.textColor),
                  decoration: InputDecoration(
                    hintText: 'Card Number',
                    hintStyle: GoogleFonts.outfit(
                      color: context.subtextColor,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: expiryController,
                        onChanged: (val) => setModalState(() {}),
                        style: GoogleFonts.outfit(color: context.textColor),
                        decoration: InputDecoration(
                          hintText: 'MM/YY',
                          hintStyle: GoogleFonts.outfit(
                            color: context.subtextColor,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: cvvController,
                        obscureText: true,
                        style: GoogleFonts.outfit(color: context.textColor),
                        decoration: InputDecoration(
                          hintText: 'CVV',
                          hintStyle: GoogleFonts.outfit(
                            color: context.subtextColor,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: nameController,
                  onChanged: (val) => setModalState(() {}),
                  style: GoogleFonts.outfit(color: context.textColor),
                  decoration: InputDecoration(
                    hintText: 'Cardholder Name',
                    hintStyle: GoogleFonts.outfit(
                      color: context.subtextColor,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                SizedBox(height: 25.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (cardNumberController.text.isNotEmpty &&
                          expiryController.text.isNotEmpty &&
                          cvvController.text.isNotEmpty) {
                        Navigator.pop(context);
                        _placeOrder();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRose,
                    ),
                    child: Text(
                      'AUTHORIZE & PAY',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderSuccessDialog(
    BuildContext context,
    String orderId,
    double total,
    double packagingFee,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 25.w),
        child: FadeInUp(
          child: Container(
            padding: EdgeInsets.all(30.w),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZoomIn(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green.shade400,
                      size: 60.sp,
                    ),
                  ),
                ),
                SizedBox(height: 25.h),
                Text(
                  'Order Placed!',
                  style: GoogleFonts.outfit(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Your order has been successfully placed. Download the invoice PDF below or view tracking status.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    color: context.subtextColor,
                  ),
                ),
                SizedBox(height: 25.h),

                OutlinedButton.icon(
                  onPressed: () {
                    final user = FirebaseAuth.instance.currentUser;
                    final items = CartService().items
                        .map(
                          (e) => {
                            'name': e['name'],
                            'price': '\$${e['price'].toString()}',
                            'qty': e['qty'],
                          },
                        )
                        .toList();

                    PdfInvoiceService.generateAndShareInvoice(
                      orderId: orderId,
                      userName:
                          user?.displayName ??
                          user?.email?.split('@').first ??
                          'Customer',
                      items: items,
                      totalPrice: '\$${total.toStringAsFixed(2)}',
                      paymentMethod: _paymentMethod,
                      address: _selectedAddress,
                      discount: _discount,
                      packagingFee: packagingFee,
                    );
                  },
                  icon: Icon(Icons.picture_as_pdf, color: AppTheme.primaryRose),
                  label: Text(
                    'Share PDF Invoice',
                    style: GoogleFonts.outfit(
                      color: AppTheme.primaryRose,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryRose),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      CartService().clearCart();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRose,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                    child: Text(
                      'Back to Shopping',
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
    final cartItems = CartService().items;
    final subtotal = CartService().subtotal;
    double packagingFee = _useGiftPackaging ? 5.00 : 0.00;
    double total = subtotal - _discount + packagingFee;

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          _checkoutStep == 0
              ? 'My Cart'
              : (_checkoutStep == 1 ? 'Delivery Details' : 'Payment Method'),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: context.textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (_checkoutStep == 2) {
              setState(() => _checkoutStep = 1);
            } else if (_checkoutStep == 1) {
              setState(() => _checkoutStep = 0);
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20.sp,
            color: context.textColor,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: cartItems.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.w,
                        vertical: 6.h,
                      ),
                      child: Row(
                        children: [
                          _buildStepIcon(
                            Icons.shopping_cart_outlined,
                            'Cart',
                            true,
                            _checkoutStep == 0,
                          ),
                          Expanded(
                            child: Container(
                              height: 2.h,
                              margin: EdgeInsets.symmetric(horizontal: 6.w),
                              decoration: BoxDecoration(
                                color: _checkoutStep >= 1
                                    ? AppTheme.primaryRose
                                    : context.borderColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          _buildStepIcon(
                            Icons.local_shipping_outlined,
                            'Delivery',
                            _checkoutStep >= 1,
                            _checkoutStep == 1,
                          ),
                          Expanded(
                            child: Container(
                              height: 2.h,
                              margin: EdgeInsets.symmetric(horizontal: 6.w),
                              decoration: BoxDecoration(
                                color: _checkoutStep >= 2
                                    ? AppTheme.primaryRose
                                    : context.borderColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          _buildStepIcon(
                            Icons.payments_outlined,
                            'Payment',
                            _checkoutStep >= 2,
                            _checkoutStep == 2,
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: _checkoutStep == 0
                            ? _buildStep0CartView(
                                cartItems,
                                key: const ValueKey(0),
                              )
                            : (_checkoutStep == 1
                                  ? _buildStep1DeliveryView(
                                      key: const ValueKey(1),
                                    )
                                  : _buildStep2PaymentView(
                                      key: const ValueKey(2),
                                    )),
                      ),
                    ),

                    SafeArea(
                      top: false,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _shipRow(
                              'Subtotal',
                              '\$${subtotal.toStringAsFixed(2)}',
                            ),
                            if (_discount > 0) ...[
                              SizedBox(height: 2.h),
                              _shipRow(
                                'Discount',
                                '-\$${_discount.toStringAsFixed(2)}',
                                isGreen: true,
                              ),
                            ],
                            if (_useGiftPackaging) ...[
                              SizedBox(height: 2.h),
                              _shipRow('Gift Packaging', '+\$5.00'),
                            ],
                            SizedBox(height: 2.h),
                            _shipRow('Shipping', 'FREE', isGreen: true),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Divider(
                                height: 1,
                                color: context.borderColor,
                              ),
                            ),
                            _shipRow(
                              'Total',
                              '\$${total.toStringAsFixed(2)}',
                              isBold: true,
                            ),
                            SizedBox(height: 6.h),

                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: _isPlacingOrder
                                    ? null
                                    : () {
                                        if (_checkoutStep == 0) {
                                          setState(() => _checkoutStep = 1);
                                        } else if (_checkoutStep == 1) {
                                          setState(() => _checkoutStep = 2);
                                        } else {
                                          _processCheckout();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryRose,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                child: _isPlacingOrder
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _checkoutStep == 0
                                                ? 'Continue to Delivery →'
                                                : (_checkoutStep == 1
                                                      ? 'Continue to Payment →'
                                                      : 'Checkout →'),
                                            style: GoogleFonts.outfit(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (_checkoutStep == 2) ...[
                                            SizedBox(width: 8.w),
                                            Icon(
                                              Icons.check_circle_outline,
                                              size: 18.sp,
                                            ),
                                          ],
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStep0CartView(List<Map<String, dynamic>> cartItems, {Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),

          ...cartItems.asMap().entries.map(
            (entry) => _buildCartItem(entry.key, entry.value),
          ),
          SizedBox(height: 4.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_offer_outlined,
                      color: AppTheme.primaryRose,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Have a Coupon?',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: context.textColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _couponController,
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          color: context.textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter coupon code',
                          hintStyle: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: context.subtextColor,
                          ),
                          filled: true,
                          fillColor: context.scaffoldBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 10.h,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    ElevatedButton(
                      onPressed: _verifyCoupon,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRose,
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 14.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Apply',
                        style: GoogleFonts.outfit(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_discount > 0) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Coupon applied! You save \$${_discount.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          color: Colors.green,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildStep1DeliveryView({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          _buildSectionLabel(' Delivery Address'),
          SizedBox(height: 10.h),
          _isLoadingAddresses
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryRose),
                )
              : _addresses.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        color: context.subtextColor,
                        size: 32.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No shipping addresses saved',
                        style: GoogleFonts.outfit(
                          color: context.subtextColor,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddressesScreen(),
                            ),
                          );
                          _loadAddresses();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRose,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add_location_alt_outlined,
                          size: 16,
                        ),
                        label: Text(
                          'Add Address',
                          style: GoogleFonts.outfit(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppTheme.primaryRose.withValues(alpha: 0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedAddress,
                      isExpanded: true,
                      dropdownColor: context.surfaceColor,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.primaryRose,
                      ),
                      items: _addresses.map((addr) {
                        return DropdownMenuItem(
                          value: addr,
                          child: Text(
                            addr,
                            style: GoogleFonts.outfit(
                              color: context.textColor,
                              fontSize: 13.sp,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedAddress = val),
                    ),
                  ),
                ),
          SizedBox(height: 20.h),

          _buildSectionLabel(' Add-ons'),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: _useGiftPackaging
                  ? AppTheme.primaryRose.withValues(alpha: 0.05)
                  : context.surfaceColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: _useGiftPackaging
                    ? AppTheme.primaryRose.withValues(alpha: 0.4)
                    : context.borderColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _useGiftPackaging,
                      activeColor: AppTheme.primaryRose,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _useGiftPackaging = val ?? false;
                          _discount = CartService().subtotal * _discountPercent;
                        });
                      },
                    ),
                    Icon(
                      Icons.card_giftcard_outlined,
                      color: AppTheme.primaryRose,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Premium Gift Packaging',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: context.textColor,
                            ),
                          ),
                          Text(
                            'Luxury box, ribbon & greeting card — only +\$5.00',
                            style: GoogleFonts.outfit(
                              color: context.subtextColor,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_useGiftPackaging) ...[
                  SizedBox(height: 10.h),
                  TextField(
                    controller: _giftCardMessageController,
                    maxLines: 2,
                    style: GoogleFonts.outfit(
                      color: context.textColor,
                      fontSize: 12.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Your personal greeting message...',
                      hintStyle: GoogleFonts.outfit(
                        color: context.subtextColor,
                        fontSize: 11.sp,
                      ),
                      filled: true,
                      fillColor: context.scaffoldBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildStep2PaymentView({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildSectionLabel('💳 Payment Method'),
          SizedBox(height: 12.h),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 2.8,
            children: [
              _buildPaymentOption(
                'COD',
                Icons.payments_outlined,
                'Cash on Delivery',
              ),
              _buildPaymentOption(
                'Card',
                Icons.credit_card_outlined,
                'Credit/Debit',
              ),
              _buildPaymentOption(
                'JazzCash',
                Icons.account_balance_wallet_outlined,
                'JazzCash',
              ),
              _buildPaymentOption(
                'EasyPaisa',
                Icons.wallet_outlined,
                'EasyPaisa',
              ),
            ],
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: context.textColor,
      ),
    );
  }

  Widget _buildStepIcon(
    IconData icon,
    String label,
    bool isActive,
    bool isCurrent,
  ) {
    Color mainColor = isCurrent
        ? AppTheme.primaryRose
        : (isActive
              ? AppTheme.primaryRose.withValues(alpha: 0.7)
              : context.subtextColor.withValues(alpha: 0.4));
    Color bgColor = isCurrent
        ? AppTheme.primaryRose.withValues(alpha: 0.15)
        : (isActive
              ? AppTheme.primaryRose.withValues(alpha: 0.05)
              : context.surfaceColor);
    Color borderColor = isCurrent
        ? AppTheme.primaryRose
        : (isActive
              ? AppTheme.primaryRose.withValues(alpha: 0.5)
              : context.borderColor);
    Color textColor = isCurrent
        ? context.textColor
        : (isActive
              ? context.subtextColor
              : context.subtextColor.withValues(alpha: 0.6));

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Icon(icon, color: mainColor, size: 16.sp),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 9.sp,
            color: textColor,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(int index, Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDarkMode ? 0.2 : 0.01,
            ),
            blurRadius: 5,
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                image: DecorationImage(
                  image: NetworkImage(item['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: context.textColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Qty: ${item['qty']}',
                    style: GoogleFonts.outfit(
                      color: context.subtextColor,
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '\$${item['price']}',
                    style: GoogleFonts.outfit(
                      color: AppTheme.primaryRose,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 85.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => CartService().removeItem(index),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red.shade300,
                      size: 20.sp,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _qtyBtn(
                        Icons.remove,
                        () => CartService().updateQuantity(index, -1),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          item['qty'].toString(),
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                            color: context.textColor,
                          ),
                        ),
                      ),
                      _qtyBtn(
                        Icons.add,
                        () => CartService().updateQuantity(index, 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 80.sp,
              color: context.subtextColor.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No Cart Yet!',
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: context.textColor,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Explore more and shortlist some products.',
            style: GoogleFonts.outfit(color: context.subtextColor),
          ),
          SizedBox(height: 30.h),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRose,
              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
            ),
            child: const Text('Go Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: context.scaffoldBg,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 12.sp, color: context.textColor),
      ),
    );
  }

  Widget _buildPaymentOption(String id, IconData icon, String label) {
    bool isSelected = _paymentMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = id),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryRose.withValues(alpha: 0.05)
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRose : context.borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryRose : context.subtextColor,
              size: 18.sp,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppTheme.primaryRose
                      : context.subtextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shipRow(
    String title,
    String val, {
    bool isBold = false,
    bool isGreen = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: isBold ? context.textColor : context.subtextColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontSize: 13.sp,
          ),
        ),
        Text(
          val,
          style: GoogleFonts.outfit(
            color: isGreen ? Colors.green.shade400 : context.textColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 15.sp : 13.sp,
          ),
        ),
      ],
    );
  }
}
