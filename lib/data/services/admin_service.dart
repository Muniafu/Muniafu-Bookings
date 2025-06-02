import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin.dart';

class AdminService {
  final String? baseUrl;  // Nullable for Firestore-only operations
  final FirebaseFirestore? firestore;  // Nullable for HTTP-only operations

  AdminService({this.baseUrl, this.firestore}) {
    // Validate required dependencies
    assert(
      baseUrl != null || firestore != null, 
      'Must provide either baseUrl or firestore instance'
    );
  }

  // Firestore collection reference
  CollectionReference get _adminCollection => 
      firestore!.collection('admins');
      
  CollectionReference get _paymentCollection => 
      firestore!.collection('payments');

  // HTTP API Methods
  Future<List<Map<String, dynamic>>> getAllBookings() async {
    return _handleHttpRequest(
      request: () => http.get(Uri.parse('$baseUrl/admin/bookings')),
      processResponse: (response) => 
          List<Map<String, dynamic>>.from(jsonDecode(response.body)),
      errorMessage: 'Failed to fetch bookings',
    );
  }

  Future<List<Map<String, dynamic>>> getHotelListings() async {
    return _handleHttpRequest(
      request: () => http.get(Uri.parse('$baseUrl/admin/hotels')),
      processResponse: (response) => 
          List<Map<String, dynamic>>.from(jsonDecode(response.body)),
      errorMessage: 'Failed to fetch hotel listings',
    );
  }

  Future<void> approveRoom(String roomId) async {
    await _handleHttpRequest(
      request: () => http.post(
        Uri.parse('$baseUrl/admin/rooms/$roomId/approve')
      ),
      errorMessage: 'Failed to approve room',
    );
  }

  Future<void> rejectRoom(String roomId) async {
    await _handleHttpRequest(
      request: () => http.post(
        Uri.parse('$baseUrl/admin/rooms/$roomId/reject')
      ),
      errorMessage: 'Failed to reject room',
    );
  }

  // Firestore Admin Methods
  Future<void> addAdmin(Admin admin) async {
    await _handleFirestoreOperation(
      operation: () => _adminCollection.doc(admin.id).set(admin.toFirestore()),
      errorMessage: 'Failed to add admin',
    );
  }

  Future<Admin?> getAdmin(String id) async {
    return _handleFirestoreOperation<Admin?>(
      operation: () async {
        final snapshot = await _adminCollection.doc(id).get();
        return snapshot.exists 
            ? Admin.fromFirestore(snapshot) 
            : null;
      },
      errorMessage: 'Failed to get admin',
    );
  }

  Future<bool> canManageHotel(String adminId, String hotelId) async {
    return _handleFirestoreOperation<bool>(
      operation: () async {
        final admin = await getAdmin(adminId);
        return admin?.managesHotel(hotelId) ?? false;
      },
      errorMessage: 'Failed to check hotel management permission',
    );
  }

  Future<void> updateAdminPermissions({
    required String adminId,
    required List<String> managedHotels,
  }) async {
    await _handleFirestoreOperation(
      operation: () => _adminCollection.doc(adminId).update({
        'managedHotels': managedHotels,
        'updatedAt': FieldValue.serverTimestamp(),
      }),
      errorMessage: 'Failed to update admin permissions',
    );
  }

  // Payment Methods
  Future<void> addPayment(String payment) async {
    await _handleFirestoreOperation(
      operation: () => _paymentCollection.add({
        'description': payment,
        'createdAt': FieldValue.serverTimestamp(),
      }),
      errorMessage: 'Failed to add payment',
    );
  }

  Future<List<String>> fetchPayments() async {
    return _handleFirestoreOperation<List<String>>(
      operation: () async {
        final snapshot = await _paymentCollection
            .orderBy('createdAt', descending: true)
            .get();
        
        return snapshot.docs
            .map((doc) => doc.get('description') as String? ?? '')
            .where((desc) => desc.isNotEmpty)
            .toList();
      },
      errorMessage: 'Failed to fetch payments',
    );
  }

  // Centralized HTTP handler
  Future<T> _handleHttpRequest<T>({
    required Future<http.Response> Function() request,
    T Function(http.Response)? processResponse,
    required String errorMessage,
  }) async {
    try {
      final response = await request();
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return processResponse != null 
            ? processResponse(response) 
            : () as T;  // Safe cast for void operations
      } else {
        throw AdminServiceException(
          '$errorMessage: ${response.statusCode} - ${response.body}'
        );
      }
    } catch (e) {
      throw AdminServiceException(
        e is AdminServiceException ? e.message : '$errorMessage: ${e.toString()}'
      );
    }
  }

  // Centralized Firestore handler
  Future<T> _handleFirestoreOperation<T>({
    required Future<T> Function() operation,
    required String errorMessage,
  }) async {
    try {
      return await operation();
    } on FirebaseException catch (e) {
      throw AdminServiceException('$errorMessage: ${e.message}');
    } catch (e) {
      throw AdminServiceException(
        e is AdminServiceException ? e.message : '$errorMessage: ${e.toString()}'
      );
    }
  }
}

class AdminServiceException implements Exception {
  final String message;
  AdminServiceException(this.message);

  @override
  String toString() => 'AdminServiceException: $message';
}