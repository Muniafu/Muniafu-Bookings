import 'package:flutter/material.dart';
import '../data/services/user_service.dart';
import '../data/models/user.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;
  User? _user;
  bool _isLoading = false;
  String? _error;

  UserProvider() : _userService = UserService();

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch user details
  Future<void> fetchUser(String uid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _userService.getUser(uid);
    } catch (e) {
      _error = 'Failed to load user data: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user
  Future<void> updateUser(User user) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userService.updateUserModel(user); // Using updateUserModel instead of updateUser
      _user = user;
    } catch (e) {
      _error = 'Failed to update user: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new user
  Future<void> createUser(User user) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userService.createUser(user);
      _user = user;
    } catch (e) {
      _error = 'Failed to create user: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
  if (_user != null) {
    await fetchUser(_user!.id);
    }
  }

  // Clear user data (for logout)
  void clearUser() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}