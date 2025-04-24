import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';  // Your custom User model

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final CollectionReference _userCollection = 
      FirebaseFirestore.instance.collection('users');

  // Current user stream (using Firebase User)
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Current user getter (using Firebase User)
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Register with email and password
  Future<firebase_auth.User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String role = 'user',
  }) async {
    try {
      final firebase_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      await _createUserProfile(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
      );

      return userCredential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final firebase_auth.User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      final DocumentSnapshot userDoc =
          await _userCollection.doc(firebaseUser.uid).get();

      return userDoc.exists ? User.fromFirestore(userDoc) : null;
    } catch (e) {
      throw AuthException('Failed to fetch current user: ${e.toString()}');
    }
  }

  Future<User?> getUser(String uid) async {
    try {
      final DocumentSnapshot userDoc = await _userCollection.doc(uid).get();
      return userDoc.exists ? User.fromFirestore(userDoc) : null;
    } catch (e) {
      throw AuthException('Failed to fetch user: ${e.toString()}');
    }
  }

  // Login with email and password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final firebase_auth.UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      
      return await getUser(userCredential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = 
          await googleUser?.authentication;

      final firebase_auth.AuthCredential credential = 
          firebase_auth.GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
          );

      final firebase_auth.UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserProfile(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email!,
          name: userCredential.user!.displayName ?? 'Google User',
          role: 'user',
        );
      }

      return await getUser(userCredential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Google sign-in failed: ${e.toString()}');
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Logout failed: ${e.toString()}');
    }
  }

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