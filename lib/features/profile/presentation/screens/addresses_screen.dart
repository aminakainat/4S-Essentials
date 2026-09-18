import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_4sessentials/core/theme.dart';
import 'package:flutter_4sessentials/core/services/firestore_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final List<String> _addresses = [];
  bool _isLoading = true;
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
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
          _addresses.clear();
          _addresses.addAll(list.map((e) => e.toString()));
        });
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addAddress() async {
    final text = _addressController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      _addresses.add(text);
      await FirestoreService().saveUserProfile(user.uid, {
        'addresses': _addresses,
      });
      _addressController.clear();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address added successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      _loadAddresses();
    }
  }

  void _deleteAddress(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      _addresses.removeAt(index);
      await FirestoreService().saveUserProfile(user.uid, {
        'addresses': _addresses,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address deleted!'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      _loadAddresses();
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                'Add Shipping Address',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  color: context.textColor,
                ),
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: _addressController,
                maxLines: 3,
                style: GoogleFonts.outfit(color: context.textColor),
                decoration: InputDecoration(
                  hintText: 'Enter full address details...',
                  hintStyle: GoogleFonts.outfit(color: context.subtextColor, fontSize: 13.sp),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _addAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRose,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                  ),
                  child: Text(
                    'Save Address',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'DELIVERY ADDRESSES',
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
            onPressed: _showAddDialog,
            icon: Icon(Icons.add_location_alt_outlined, color: AppTheme.primaryRose, size: 22.sp),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose))
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_outlined, size: 60.sp, color: context.subtextColor),
                      SizedBox(height: 15.h),
                      Text(
                        'No shipping addresses added yet.',
                        style: GoogleFonts.outfit(color: context.subtextColor, fontSize: 14.sp),
                      ),
                      SizedBox(height: 15.h),
                      ElevatedButton(
                        onPressed: _showAddDialog,
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
                        child: Text('Add First Address', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 15.h),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 15.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.02),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: AppTheme.primaryRose, size: 24.sp),
                          SizedBox(width: 15.w),
                          Expanded(
                            child: Text(
                              _addresses[index],
                              style: GoogleFonts.outfit(
                                color: context.textColor,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _deleteAddress(index),
                            icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade300, size: 20.sp),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
