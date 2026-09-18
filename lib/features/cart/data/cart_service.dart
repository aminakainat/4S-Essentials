import 'package:flutter/material.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addItem(Map<String, dynamic> product, int quantity) {
    // Check if product already exists
    int index = _items.indexWhere((item) => item['name'] == product['name']);
    if (index != -1) {
      _items[index]['qty'] += quantity;
    } else {
      _items.add({
        'name': product['name'],
        'price': double.parse(product['price'].toString().replaceAll('\$', '').replaceAll(',', '')),
        'qty': quantity,
        'image': product['image'],
        'material': 'Premium', // Default or from product
      });
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void updateQuantity(int index, int delta) {
    _items[index]['qty'] += delta;
    if (_items[index]['qty'] <= 0) {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  double get subtotal => _items.fold(0, (sum, item) => sum + (item['price'] * item['qty']));

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
