import 'package:flutter/material.dart';

class User {
  String name;
  String email;

  User({required this.name, required this.email});
}

ValueNotifier<User> userNotifier = ValueNotifier(
  User(name: 'John Doe', email: 'john.doe@example.com'),
);
