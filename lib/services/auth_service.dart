import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<User?> registerUser(String email, String password, String name, String role) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Add user details to Firestore
      await userCollection.doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
        'role': role,
      });

      return userCredential.user;
    } catch (e) {
      throw Exception('Failed to register user: $e');
    }
  }

  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      throw Exception('Failed to login user $e');
    }
  }

  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to logout user: $e');
    }
  }
}