import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _name = 'User Name';
  String _email = 'user@example.com';
  String _phone = '123-456-7890'; // Example phone number
  String _profileImageUrl = '';
  bool _notificationsEnabled = true;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get profileImageUrl => _profileImageUrl;
  bool get notificationsEnabled => _notificationsEnabled;

  void updateUser({
    required String name,
    required String email,
    required String phone,
  }) {
    _name = name;
    _email = email;
    _phone = phone; // Uncomment and implement if you have a _phone field
    // _phone = phone; // Uncomment and implement if you have a _phone field
    notifyListeners();
  }

  Future<void> updateProfileImage(File image) async {
    _profileImageUrl =
        image.path; // Store file path (replace with server URL in production)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_url', _profileImageUrl);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear user data
    _name = 'User Name';
    _email = 'user@example.com';
    _profileImageUrl = '';
    _notificationsEnabled = true;
    notifyListeners();
  }

  Future<void> updateProfile(String name, String email) async {
    _name = name;
    _email = email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _name);
    await prefs.setString('user_email', _email);
    notifyListeners();
  }
}
