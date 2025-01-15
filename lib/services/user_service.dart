import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final CollectionReference userCollection =
    FirebaseFirestore.instance.collection('users');

  Future<Map<String, dynamic>?> getUserById(String id) async {
    try {
      DocumentSnapshot snapshot = await userCollection.doc(id).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      throw Exception('Failed to get user $e');
    }
    return null;
  }

  Future<void> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      await userCollection.doc(id).update(updates);
    } catch (e) {
      throw Exception('Failed to update user $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await userCollection.get();
      return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    } catch (e) {
      throw Exception('Failed to get users $e');
    }
  }
}