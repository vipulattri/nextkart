import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  double get totalPrice {
    return _items.fold(0.0, (sum, item) {
      // Convert price and quantity to double
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      final quantity = (item['quantity'] as num?)?.toDouble() ?? 1.0;
      return sum + (price * quantity);
    });
  }

  void addItem(Map<String, dynamic> product) {
    final index = _items.indexWhere((item) => item['name'] == product['name']);
    if (index != -1) {
      _items[index]['quantity'] = (_items[index]['quantity'] ?? 1) + 1;
    } else {
      _items.add({...product, 'quantity': product['quantity'] ?? 1});
    }
    notifyListeners();
  }

  void increaseQuantity(String name) {
    final index = _items.indexWhere((item) => item['name'] == name);
    if (index != -1 && (_items[index]['stock'] ?? true)) {
      _items[index]['quantity'] = (_items[index]['quantity'] ?? 1) + 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(String name) {
    final index = _items.indexWhere((item) => item['name'] == name);
    if (index != -1 && (_items[index]['quantity'] ?? 1) > 1) {
      _items[index]['quantity'] = (_items[index]['quantity'] ?? 1) - 1;
      notifyListeners();
    } else if (index != -1 && (_items[index]['quantity'] ?? 1) == 1) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void removeItem(String name) {
    _items.removeWhere((item) => item['name'] == name);
    notifyListeners();
  }
}
