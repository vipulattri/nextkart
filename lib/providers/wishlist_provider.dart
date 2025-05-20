import 'package:flutter/material.dart';

class WishlistProvider with ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => _items;
  bool isInWishlist(String name) => _items.any((item) => item['name'] == name);
  void toggleWishlist(Map<String, dynamic> product) {
    if (isInWishlist(product['name'])) {
      _items.removeWhere((item) => item['name'] == product['name']);
    } else {
      _items.add(product);
    }
    notifyListeners();
  }
}

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> get items => _items;
  void addItem(Map<String, dynamic> product) {
    final existingItem = _items.firstWhere(
      (item) => item['name'] == product['name'],
      orElse: () => {},
    );
    if (existingItem.isNotEmpty) {
      existingItem['quantity'] = (existingItem['quantity'] as num) + 1;
    } else {
      _items.add({...product, 'quantity': 1});
    }
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(0.0, (sum, item) {
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = (item['quantity'] as num?)?.toDouble() ?? 1.0;
      return sum + (price * quantity);
    });
  }
}
