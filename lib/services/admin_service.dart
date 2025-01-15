import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  // Reference to the Firestore collection for admins
  final CollectionReference adminCollection =
      FirebaseFirestore.instance.collection('admins');

  // Add an admin document to the Firestore collection
  Future<void> addAdmin(String id, Map<String, dynamic> adminData) async {
    try {
      await adminCollection.doc(id).set(adminData);
    } catch (e) {
      throw Exception('Failed to add admin: $e');
    }
  }

  // Retrieve an admin document by ID from Firestore
  Future<Map<String, dynamic>?> getAdminById(String id) async {
    try {
      DocumentSnapshot snapshot = await adminCollection.doc(id).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      throw Exception('Failed to get admin: $e');
    }
    return null;
  }
}