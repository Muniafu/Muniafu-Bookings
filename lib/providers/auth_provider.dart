import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';
import '../data/models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService);

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _user?.role == 'admin';
  String? get userId => _user?.id;

  // Initialize authentication state
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _user = await _authService.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize session: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Handle registration
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await _performAuthOperation(() async {
      await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );
      
      // Refresh user after registration
      _user = await _authService.getCurrentUser();
    });
  }

  // Handle login
  Future<void> login(String email, String password) async {
    await _performAuthOperation(() async {
      _user = await _authService.loginWithEmail(email, password);
    });
  }

  // Handle logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _error = null;
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Handle password reset
  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      _error = null;
    } catch (e) {
      _error = e is AuthException 
          ? e.message 
          : 'Password reset failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Optional REST authentication methods
  Future<void> restLogin(String email, String password) async {
    await _performAuthOperation(() async {
      _user = await _authService.restLogin(email, password);
    });
  }

  Future<void> restSignup(String email, String password) async {
    await _performAuthOperation(() async {
      _user = await _authService.restSignup(email, password);
    });
  }

  // Private helper methods ===============================================

  // Unified authentication operation handler
  Future<void> _performAuthOperation(Future<void> Function() operation) async {
    _resetState();
    try {
      await operation();
      _error = null;
    } catch (e) {
      _error = e is AuthException 
          ? e.message 
          : 'Authentication failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void _resetState() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}