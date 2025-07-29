import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';
import '../data/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _role;
  String? _error;
  bool _isLoading = false;

  AuthProvider(AuthService authService);
  String? get role => _role;
  String? get error => _error;
  bool get isLoading => _isLoading;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> register ({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

      // save extra user ifo like name in Firestore
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'name': name,
        'role': 'user', // default role
        'createdAt': FieldValue.serverTimestamp(),
      });

      _error = null;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Registration failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async  {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Login failed. Try again';
    } catch (e) {
      _error = 'Unexpected error. Please try again.';
    }
  }

  Future<void> fetchUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await _firestore.collection('users').doc(uid).get();
    _role = doc.data()?['role'] ?? 'user'; // default to user
    notifyListeners();
  }

  bool get isAdmin => _role == 'admin';

  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw AuthException('Failed to send reset email: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}