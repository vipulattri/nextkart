import 'package:flutter/material.dart';
import 'package:nexkart6/models/adrees.dart';

class AddressProvider with ChangeNotifier {
  final List<Address> _addresses = [];

  List<Address> get addresses => List.unmodifiable(_addresses);

  void addAddress(Address address) {
    _addresses.add(address);
    notifyListeners();
  }

  void removeAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void updateAddress(Address updated) {
    final index = _addresses.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _addresses[index] = updated;
      notifyListeners();
    }
  }
}
