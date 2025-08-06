import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../data/models/user.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  String? _role;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get role => _role;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _role == 'admin';

  AuthProvider({AuthService? authService}) 
    : _authService = authService ?? AuthService.defaultInstance();

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Authentication Methods ==============================================

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? fullName,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        fullName: fullName,
        phone: phone,
      );
      await _saveUserIdToStorage(_currentUser!.uid);
      await _fetchUserRole();
      _error = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      _currentUser = await _authService.login(email, password);
      await _saveUserIdToStorage(_currentUser!.uid);
      await _fetchUserRole();
      _error = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_uid');
    
    _currentUser = null;
    _role = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _authService.resetPassword(email);
      _error = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Password reset failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentUser() async {
    _setLoading(true);
    try {
      _currentUser = await _authService.getCurrentUser();
      if (_currentUser != null) {
        await _saveUserIdToStorage(_currentUser!.uid);
        await _fetchUserRole();
      }
      _error = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to load user: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // User Management =====================================================

  Future<void> _fetchUserRole() async {
    if (_currentUser == null) {
      await _loadUserFromStorage();
    }
    
    _role = _currentUser?.role ?? 'user';
    notifyListeners();
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('auth_uid');

    if (uid != null) {
      try {
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          _currentUser = User.fromFirestore(doc);
          _role = doc['role'] ?? 'user';
        }
      } catch (e) {
        debugPrint('Failed to load user from storage: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _saveUserIdToStorage(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_uid', uid);
  }

  Future<void> changePassword(String newPassword) async {
    _setLoading(true);
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.updatePassword(newPassword);
      }
      _error = null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = e.message ?? 'Password change failed';
    } catch (e) {
      _error = 'Unexpected error: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBasicProfile(String fullName, String phone) async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'full_name': fullName,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _currentUser = _currentUser!.copyWith(
        fullName: fullName,
        phone: phone,
      );

      notifyListeners();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? fullName,
    String? phone,
    String? bio,
    String? location,
    bool? darkMode,
  }) async {
    if (_currentUser == null) return;

    _setLoading(true);
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (fullName != null) updates['fullName'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (bio != null) updates['bio'] = bio;
      if (location != null) updates['location'] = location;
      if (darkMode != null) updates['darkMode'] = darkMode;

      await _firestore.collection('users').doc(_currentUser!.uid).update(updates);

      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        fullName: fullName ?? _currentUser!.fullName,
        phone: phone ?? _currentUser!.phone,
        bio: bio ?? _currentUser!.bio,
        location: location ?? _currentUser!.location,
        darkMode: darkMode ?? _currentUser!.darkMode,
      );

      _error = null;
    } catch (e) {
      _error = 'Profile update failed: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyEmail() async {
    _setLoading(true);
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null && !firebaseUser.emailVerified) {
        await firebaseUser.sendEmailVerification();
      }
      _error = null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _error = e.message ?? 'Email verification failed';
    } catch (e) {
      _error = 'Unexpected error: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}