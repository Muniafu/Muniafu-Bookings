import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/services/admin_service.dart';
import '../data/models/admin.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _service;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // State management
  Admin? _admin;
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _hotels = [];
  List<String> _payments = [];
  bool _isLoading = false;
  String? _error;
  bool _isAdmin = false;
  String? _email;

  // Loading states for different operations
  final Map<String, bool> _loadingStates = {
    'dashboard': false,
    'hotels': false,
    'payments': false,
    'auth': false,
  };

  AdminProvider(this._service);

  // Getters
  Admin? get admin => _admin;
  List<Map<String, dynamic>> get bookings => List.unmodifiable(_bookings);
  List<Map<String, dynamic>> get hotels => List.unmodifiable(_hotels);
  List<String> get payments => List.unmodifiable(_payments);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _isAdmin;
  String? get adminEmail => _email;

  // Centralized state handler
  Future<void> _handleOperation(Future<void> Function() operation, {String? loadingKey}) async {
    try {
      _setLoading(true, key: loadingKey);
      _error = null;
      await operation();
    } catch (e) {
      _setError('Operation failed: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false, key: loadingKey);
    }
  }

  void _setLoading(bool state, {String? key}) {
    if (key != null) {
      _loadingStates[key] = state;
    } else {
      _isLoading = state;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    debugPrint('AdminProvider Error: $message');
    notifyListeners();
  }

  // Authentication operations
  Future<void> login(String email, String password) => _handleOperation(() async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final adminDoc = await _db.collection('admins').doc(result.user!.uid).get();

    if (adminDoc.exists && adminDoc.data()?['active'] == true) {
      _isAdmin = true;
      _email = email;
      _error = null;
      await fetchAdmin(result.user!.uid); // Load admin profile after successful login
    } else {
      _error = 'Not authorized as admin';
      _isAdmin = false;
      await _auth.signOut();
      throw Exception(_error);
    }
  }, loadingKey: 'auth');

  Future<void> logout() async {
    await _auth.signOut();
    _isAdmin = false;
    _email = null;
    _admin = null;
    notifyListeners();
  }

  // Admin profile operations
  Future<void> fetchAdmin(String adminId) => _handleOperation(() async {
    if (adminId.isEmpty) throw ArgumentError('Admin ID cannot be empty');
    _admin = await _service.getAdmin(adminId);
  });

  Future<void> updatePermissions(List<String> newPermissions) => _handleOperation(() async {
    if (_admin == null) return;
    
    await _service.updateAdminPermissions(
      adminId: _admin!.id,
      managedHotels: newPermissions,
    );
    
    _admin = _admin!.copyWith(permissions: newPermissions);
  });

  // Dashboard operations
  Future<void> loadDashboardData() => _handleOperation(() async {
    if (_admin == null) return;
    
    final results = await Future.wait([
      _service.getAllBookings(),
      _service.getHotelListings(),
      _service.fetchPayments(),
    ]);
    
    _bookings = results[0] as List<Map<String, dynamic>>;
    _hotels = results[1] as List<Map<String, dynamic>>;
    _payments = results[2] as List<String>;
  }, loadingKey: 'dashboard');

  // Hotel management operations
  Future<void> approveRoom(String roomId) => _handleOperation(() async {
    await _service.approveRoom(roomId);
    await _refreshHotels();
  }, loadingKey: 'hotels');

  Future<void> rejectRoom(String roomId) => _handleOperation(() async {
    await _service.rejectRoom(roomId);
    await _refreshHotels();
  }, loadingKey: 'hotels');

  // Payment operations
  Future<void> addPayment(String payment) => _handleOperation(() async {
    await _service.addPayment(payment);
    _payments = [..._payments, payment];
  }, loadingKey: 'payments');

  // Helper methods
  bool canManageHotel(String hotelId) {
    return _admin != null && _admin!.managesHotel(hotelId);
  }

  bool isLoadingFor(String key) => _loadingStates[key] ?? false;

  Future<void> _refreshHotels() async {
    _hotels = await _service.getHotelListings();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}