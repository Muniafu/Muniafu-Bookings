import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  AuthProvider() {
    _initUser();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  Future<void> _initUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      _user = await _authService.getUserProfile(firebaseUser.uid);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserProfile({required String name, required String phone}) async {
    if (_user == null) return;
    await _authService.updateUserProfile(_user!.uid, name, phone);
    
    _user = UserModel(
      uid: _user!.uid,
      email: _user!.email,
      name: name,
      phone: phone,
      address: _user!.address,
      preferences: _user!.preferences,
      bookingHistory: _user!.bookingHistory,
      role: _user!.role,
    );
    notifyListeners();
  }


  Future<void> signIn(String email, String password) async {
    final firebaseUser = await _authService.signIn(email, password);
    if (firebaseUser != null) {
      _user = await _authService.getUserProfile(firebaseUser.uid);
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    final firebaseUser = await _authService.signUp(email, password, name);
    if (firebaseUser != null) {
      _user = await _authService.getUserProfile(firebaseUser.uid);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}