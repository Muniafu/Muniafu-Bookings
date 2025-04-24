import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin.dart';

class AdminService {
  final CollectionReference _adminCollection = 
      FirebaseFirestore.instance.collection('admins');

  /// Adds a new admin with typed AdminModel
  Future<void> addAdmin(Admin admin) async {
    try {
      await _adminCollection.doc(admin.id).set(admin.toJson());
    } catch (e) {
      throw AdminServiceException('Failed to add admin: ${e.toString()}');
    }
  }

  /// Adds a new admin with raw Map data
  Future<void> addAdminWithData(String id, Map<String, dynamic> adminData) async {
    try {
      await _adminCollection.doc(id).set(adminData);
    } catch (e) {
      throw AdminServiceException('Failed to add admin: ${e.toString()}');
    }
  }

  /// Gets admin by ID as AdminModel
  Future<Admin?> getAdmin(String id) async {
    try {
      final DocumentSnapshot snapshot = await _adminCollection.doc(id).get();
      if (snapshot.exists) {
        return Admin.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw AdminServiceException('Failed to get admin: ${e.toString()}');
    }
  }

  /// Gets admin data by ID as raw Map
  Future<Map<String, dynamic>?> getAdminData(String id) async {
    try {
      final DocumentSnapshot snapshot = await _adminCollection.doc(id).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw AdminServiceException('Failed to get admin data: ${e.toString()}');
    }
  }

  /// Checks if admin has permission to manage a specific hotel
  Future<bool> canManageHotel(String adminId, String hotelId) async {
    try {
      final admin = await getAdmin(adminId);
      return admin?.managesHotel(hotelId) ?? false;
    } catch (e) {
      throw AdminServiceException(
        'Failed to check hotel management permission: ${e.toString()}'
      );
    }
  }

  /// Updates admin permissions
  Future<void> updateAdminPermissions({
    required String adminId,
    required List<String> managedHotels,
  }) async {
    try {
      await _adminCollection.doc(adminId).update({
        'managedHotels': managedHotels,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw AdminServiceException(
        'Failed to update admin permissions: ${e.toString()}'
      );
    }
  }

  addPayment(String payment) {}

  fetchPayments() {}
}

class AdminServiceException implements Exception {
  final String message;
  AdminServiceException(this.message);

  @override
  String toString() => 'AdminServiceException: $message';
}