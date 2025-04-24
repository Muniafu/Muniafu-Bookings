import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';
import '../data/models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAdmin = false;

  AuthProvider(this._authService);

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _isAdmin;
  String? get userId => _user?.id;

  Future<void> register(
    String email,
    String password, {
    required String name,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 1. Register via AuthService
      await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
        role: 'user', // Default role
      );

      // 2. Fetch user data after registration
      _user = (await _authService.getCurrentUser());
      _isAdmin = _user?.isAdmin == true;

      // 3. Clear loading state
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }


  Future<void> login(String email, String password, {bool isAdminLogin = false}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // 1. Authenticate with the auth service
      final authResult = await _authService.loginWithEmail(email, password);
      
      if (authResult != null) {
        throw Exception(authResult);
      }

      // 2. Fetch user data
      _user = (await _authService.getUser(email));
      _isAdmin = isAdminLogin || _user?.isAdmin == true;

      // 3. Clear loading state
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      _isAdmin = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      _user = (await _authService.getCurrentUser());
      _isAdmin = _user?.isAdmin == true;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  sendPasswordResetEmail(String trim) {}
}