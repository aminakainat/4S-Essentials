import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Private constructor
  FirestoreService._internal();

  // Singleton instance
  static final FirestoreService _instance = FirestoreService._internal();

  // Factory constructor
  factory FirestoreService() => _instance;

  // --- PRODUCTS CRUD ---

  /// Get real-time stream of all products ordered by creation date
  Stream<QuerySnapshot> getProductsStream() {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get products filtered by category
  Stream<QuerySnapshot> getProductsByCategoryStream(String category) {
    if (category == 'All') {
      return getProductsStream();
    }
    return _db
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots();
  }

  /// Add a new product to Firestore
  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      final docRef = _db.collection('products').doc();
      final data = Map<String, dynamic>.from(productData);
      data['productId'] = docRef.id;
      data['createdAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);
    } catch (e) {
      throw 'Failed to add product: $e';
    }
  }

  /// Update an existing product in Firestore
  Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      await _db.collection('products').doc(productId).update(productData);
    } catch (e) {
      throw 'Failed to update product: $e';
    }
  }

  /// Delete a product from Firestore
  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection('products').doc(productId).delete();
    } catch (e) {
      throw 'Failed to delete product: $e';
    }
  }

  /// Seed default products if database is empty
  Future<void> seedDefaultProducts(List<Map<String, dynamic>> defaultProducts) async {
    try {
      final querySnapshot = await _db.collection('products').limit(1).get();
      if (querySnapshot.docs.isEmpty) {
        for (var product in defaultProducts) {
          final docRef = _db.collection('products').doc();
          final data = Map<String, dynamic>.from(product);
          data['productId'] = docRef.id;
          data['createdAt'] = FieldValue.serverTimestamp();
          data['stock'] = data['stock'] ?? 10;
          data['description'] = data['description'] ??
              'Crafted with precision and elegance, this piece embodies timeless luxury. Perfect for special occasions or daily sophistication.';
          await docRef.set(data);
        }
      }
    } catch (e) {
      debugPrint('Error seeding default products: $e');
    }
  }

  // --- ORDERS ---

  /// Get real-time stream of all orders
  Stream<QuerySnapshot> getOrdersStream() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get orders stream for a specific user
  Stream<QuerySnapshot> getUserOrdersStream(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Create a new order in Firestore
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    try {
      final docRef = _db.collection('orders').doc();
      final data = Map<String, dynamic>.from(orderData);
      data['orderId'] = docRef.id;
      data['createdAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);

      // Reduce stock if product details are matched in stock
      final items = data['items'] as List<dynamic>? ?? [];
      for (var item in items) {
        final name = item['name'] as String? ?? '';
        final qty = (item['qty'] as num? ?? 0).toInt();
        if (name.isNotEmpty && qty > 0) {
          final query = await _db.collection('products').where('name', isEqualTo: name).limit(1).get();
          if (query.docs.isNotEmpty) {
            final productDoc = query.docs.first;
            final currentStock = (productDoc.data()['stock'] as num? ?? 0).toInt();
            final newStock = (currentStock - qty).clamp(0, 999999);
            await productDoc.reference.update({'stock': newStock});
          }
        }
      }
    } catch (e) {
      throw 'Failed to place order: $e';
    }
  }

  /// Update the status of an order (Pending, Shipped, Delivered)
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': status,
      });
    } catch (e) {
      throw 'Failed to update order status: $e';
    }
  }

  // --- USERS ---

  /// Get real-time stream of all users
  Stream<QuerySnapshot> getUsersStream() {
    return _db.collection('users').snapshots();
  }

  /// Get a single user's profile
  Future<DocumentSnapshot> getUserProfile(String userId) async {
    try {
      return await _db.collection('users').doc(userId).get();
    } catch (e) {
      throw 'Failed to fetch user profile: $e';
    }
  }

  /// Add or update user profile details in Firestore
  Future<void> saveUserProfile(String userId, Map<String, dynamic> userData) async {
    try {
      await _db.collection('users').doc(userId).set(userData, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to save user profile: $e';
    }
  }
}
