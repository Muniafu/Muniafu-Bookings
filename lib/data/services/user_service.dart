import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muniafu/data/models/user.dart';

class UserService {
  final CollectionReference _userCollection = 
      FirebaseFirestore.instance.collection('users');

  /// Creates a new user document in Firestore
  Future<void> createUser(User user) async {
    try {
      await _userCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      throw UserServiceException('Failed to create user: ${e.toString()}');
    }
  }

  /// Retrieves a user by ID, returns null if not found
  Future<User?> getUser(String id) async {
    try {
      final DocumentSnapshot snapshot = await _userCollection.doc(id).get();
      return snapshot.exists ? User.fromFirestore(snapshot) : null;
    } catch (e) {
      throw UserServiceException('Failed to get user: ${e.toString()}');
    }
  }

  /// Updates specific fields of a user document
  Future<void> updateUser({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _userCollection.doc(id).update(updates);
    } catch (e) {
      throw UserServiceException('Failed to update user: ${e.toString()}');
    }
  }

  /// Updates an entire user model (full document replace)
  Future<void> updateUserModel(User user) async {
    try {
      await _userCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      throw UserServiceException('Failed to update user: ${e.toString()}');
    }
  }

  /// Retrieves all users from the collection
  Future<List<User>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot = await _userCollection.get();
      return snapshot.docs
          .map((doc) => User.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw UserServiceException('Failed to get all users: ${e.toString()}');
    }
  }

  /// Gets user data as raw Map
  Future<Map<String, dynamic>?> getUserData(String id) async {
    try {
      final DocumentSnapshot snapshot = await _userCollection.doc(id).get();
      return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
    } catch (e) {
      throw UserServiceException('Failed to get user data: ${e.toString()}');
    }
  }
}

class UserServiceException implements Exception {
  final String message;
  UserServiceException(this.message);

  @override
  String toString() => 'UserServiceException: $message';
}