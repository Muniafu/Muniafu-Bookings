import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  // Firebase dependencies
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  
  // SharedPreferences for token storage
  final SharedPreferences _prefs;
  
  // REST API configuration (optional)
  static const String _restBaseUrl = 'https://yourapi.com/api/auth';
  
  // Firestore collection reference
  late final CollectionReference _userCollection;

  AuthService({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required SharedPreferences prefs,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _prefs = prefs {
    _userCollection = _firestore.collection('users');
  }

  factory AuthService.defaultInstance() {
    return AuthService(
      firebaseAuth: firebase_auth.FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
      prefs: SharedPreferences.getInstance() as SharedPreferences,
    );
  }

  // Current user stream
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Current Firebase user
  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  // Token management
  Future<void> _storeToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    return _prefs.getString('auth_token');
  }

  Future<void> _removeToken() async {
    await _prefs.remove('auth_token');
  }

  // Firebase Authentication ==============================================

  Future<User> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String role = 'user',
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      await _createUserProfile(
        uid: user.uid,
        email: email,
        name: name,
        role: role,
      );

      // Store Firebase ID token for backend requests
      final token = await user.getIdToken();
      if (token != null) await _storeToken(token);

      return await getUser(user.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  Future<User> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      
      // Store Firebase ID token for backend requests
      final token = await user.getIdToken();
      if (token != null) await _storeToken(token);

      return await getUser(user.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      await _removeToken();
    } catch (e) {
      throw AuthException('Logout failed: ${e.toString()}');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;
      return await getUser(firebaseUser.uid);
    } catch (e) {
      throw AuthException('Failed to fetch current user: ${e.toString()}');
    }
  }

  Future<User> getUser(String uid) async {
    try {
      final userDoc = await _userCollection.doc(uid).get(

        // Enable offline persistence
        const GetOptions(source: Source.serverAndCache)
      );
      
      if (!userDoc.exists) throw AuthException('User not found', 'user-not-found');
      return User.fromFirestore(userDoc);
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {

        // Try to get cached data
        final cachedDoc = await _userCollection.doc(uid).get(
          const GetOptions(source: Source.cache)
        );

        if (cachedDoc.exists) {
          return User.fromFirestore(cachedDoc);
        }

        throw AuthException(
          'Network unavailable and no cached data found',
          'network-unavailable',
        );
      }
      throw AuthException('Failed to fetch user: ${e.toString()}');
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _userCollection.doc(uid).update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AuthException('Failed to update user role: ${e.toString()}');
    }
  }

  // Optional REST API Authentication =====================================
  
  Future<User?> restLogin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_restBaseUrl/login'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storeToken(data['token']);
        return User.fromJson(data['user']);
      } else {
        throw AuthException('Invalid credentials', 'invalid-credentials');
      }
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  Future<User?> restSignup(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_restBaseUrl/signup'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storeToken(data['token']);
        return User.fromJson(data['user']);
      } else {
        throw AuthException('Signup failed', 'signup-failed');
      }
    } catch (e) {
      throw AuthException('Signup failed: ${e.toString()}');
    }
  }

  Future<void> restForgotPassword(String email) async {
    try {
      await http.post(
        Uri.parse('$_restBaseUrl/forgot-password'),
        body: {'email': email},
      );
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  // Private helper methods ===============================================

  Future<void> _createUserProfile({
    required String uid,
    required String email,
    required String name,
    required String role,
  }) async {
    await _userCollection.doc(uid).set({
      'id': uid,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

class AuthException implements Exception {
  final String message;
  final String code;

  AuthException(this.message, [this.code = 'unknown']);

  factory AuthException.fromFirebaseAuthException(
      firebase_auth.FirebaseAuthException e) {
    return AuthException(e.message ?? 'Authentication failed', e.code);
  }

  @override
  String toString() => 'AuthException: $message (code: $code)';
}