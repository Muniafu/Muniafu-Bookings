import 'package:flutter/material.dart';

// authentication management
class AuthProvider with ChangeNotifier{
  String? _userId; // The ID of the logged-in user
  bool _isAdmin = false;
  
  String? get userId => _userId;
  bool get isAdmin => _isAdmin;

  // Log in a user or admin
  Future<void> login(String email, String password, bool isAdminLogin) async {
    // Simulate login process

    await Future.delayed(const Duration(seconds: 5));

    _userId = '';
    _isAdmin = isAdminLogin;
    notifyListeners();
  }

  // Log out current user
  void logout() {
    _userId = null;
    _isAdmin = false;
    notifyListeners();
  }
}