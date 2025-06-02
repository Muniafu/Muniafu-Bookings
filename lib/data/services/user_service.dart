import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user.dart';

class UserService {
  final String? _baseUrl;
  final CollectionReference? _userCollection;

  UserService._({String? baseUrl, CollectionReference? userCollection})
      : _baseUrl = baseUrl,
        _userCollection = userCollection;

  factory UserService.http(String baseUrl) {
    return UserService._(baseUrl: baseUrl);
  }

  factory UserService.firestore() {
    return UserService._(
      userCollection: FirebaseFirestore.instance.collection('users'),
    );
  }

  // Mode detection
  bool get isHttpMode => _baseUrl != null;
  bool get isFirestoreMode => _userCollection != null;

  // Common operations
  Future<User> getUserProfile(String userId) async {
    if (isHttpMode) {
      return _getHttpUserProfile(userId);
    } else if (isFirestoreMode) {
      return _getFirestoreUserProfile(userId);
    }
    throw _unsupportedError('getUserProfile');
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    if (isHttpMode) {
      return _updateHttpProfile(userId, data);
    } else if (isFirestoreMode) {
      return _updateFirestoreProfile(userId, data);
    }
    throw _unsupportedError('updateProfile');
  }

  // HTTP-specific operations
  Future<User> _getHttpUserProfile(String userId) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/users/$userId'));
      if (res.statusCode != 200) {
        throw UserServiceException(
            'Request failed with status: ${res.statusCode}');
      }
      return User.fromJson(json.decode(res.body));
    } catch (e) {
      throw UserServiceException('Failed to get user profile: ${e.toString()}');
    }
  }

  Future<void> _updateHttpProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      
      if (res.statusCode != 200) {
        throw UserServiceException(
            'Update failed with status: ${res.statusCode}');
      }
    } catch (e) {
      throw UserServiceException('HTTP update failed: ${e.toString()}');
    }
  }

  Future<void> changePassword(String userId, String newPassword) async {
    if (isHttpMode) {
      return _changeHttpPassword(userId, newPassword);
    }
    throw _unsupportedError('changePassword');
  }

  Future<void> _changeHttpPassword(String userId, String newPassword) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/users/$userId/change-password'),
        body: jsonEncode({'new_password': newPassword}),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (res.statusCode != 200) {
        throw UserServiceException(
            'Password change failed: ${res.statusCode}');
      }
    } catch (e) {
      throw UserServiceException('Password change failed: ${e.toString()}');
    }
  }

  Future<void> verifyEmail(String userId) async {
    if (isHttpMode) {
      return _verifyHttpEmail(userId);
    }
    throw _unsupportedError('verifyEmail');
  }

  Future<void> _verifyHttpEmail(String userId) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/users/$userId/verify-email'),
      );
      
      if (res.statusCode != 200) {
        throw UserServiceException(
            'Email verification failed: ${res.statusCode}');
      }
    } catch (e) {
      throw UserServiceException('Email verification failed: ${e.toString()}');
    }
  }

  // Firestore-specific operations
  Future<void> createUser(User user) async {
    if (isFirestoreMode) {
      return _createFirestoreUser(user);
    }
    throw _unsupportedError('createUser');
  }

  Future<void> _createFirestoreUser(User user) async {
    try {
      await _userCollection!.doc(user.id).set(user.toFirestore());
    } catch (e) {
      throw UserServiceException('Firestore create failed: ${e.toString()}');
    }
  }

  Future<User> _getFirestoreUserProfile(String userId) async {
    try {
      final DocumentSnapshot snapshot = 
          await _userCollection!.doc(userId).get();
          
      if (!snapshot.exists) {
        throw UserServiceException('User not found');
      }
      return User.fromFirestore(snapshot);
    } catch (e) {
      throw UserServiceException('Failed to get user profile: ${e.toString()}');
    }
  }

  Future<void> _updateFirestoreProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _userCollection!.doc(userId).update(data);
    } catch (e) {
      throw UserServiceException('Firestore update failed: ${e.toString()}');
    }
  }

  Future<void> updateUserModel(User user) async {
    if (isFirestoreMode) {
      return _updateFirestoreUserModel(user);
    }
    throw _unsupportedError('updateUserModel');
  }

  Future<void> _updateFirestoreUserModel(User user) async {
    try {
      await _userCollection!.doc(user.id).set(user.toFirestore());
    } catch (e) {
      throw UserServiceException('Failed to update user: ${e.toString()}');
    }
  }

  Future<List<User>> getAllUsers() async {
    if (isFirestoreMode) {
      return _getAllFirestoreUsers();
    }
    throw _unsupportedError('getAllUsers');
  }

  Future<List<User>> _getAllFirestoreUsers() async {
    try {
      final QuerySnapshot snapshot = await _userCollection!.get();
      return snapshot.docs
          .map((doc) => User.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw UserServiceException('Failed to get all users: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String id) async {
    if (isFirestoreMode) {
      return _getFirestoreUserData(id);
    }
    throw _unsupportedError('getUserData');
  }

  Future<Map<String, dynamic>?> _getFirestoreUserData(String id) async {
    try {
      final DocumentSnapshot snapshot = await _userCollection!.doc(id).get();
      return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
    } catch (e) {
      throw UserServiceException('Failed to get user data: ${e.toString()}');
    }
  }

  // Helper methods
  UnsupportedError _unsupportedError(String method) => UnsupportedError(
      '$method is not supported in ${isHttpMode ? 'HTTP' : 'Firestore'} mode');
}

class UserServiceException implements Exception {
  final String message;
  UserServiceException(this.message);

  @override
  String toString() => 'UserServiceException: $message';
}