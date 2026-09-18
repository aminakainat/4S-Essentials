import 'package:flutter/foundation.dart';

class RecentlyViewedManager {
  static final List<Map<String, dynamic>> items = [];
  static final ValueNotifier<int> changeNotifier = ValueNotifier(0);

  static void addProduct(Map<String, dynamic> product) {
    // Check if already in list, if yes remove to push to top
    items.removeWhere((item) => item['productId'] == product['productId']);
    
    // Insert at beginning
    items.insert(0, product);
    
    // Limit to 5 items
    if (items.length > 5) {
      items.removeLast();
    }
    
    changeNotifier.value++;
  }
}
