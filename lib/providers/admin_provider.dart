import 'package:flutter/material.dart';
import '../data/services/admin_service.dart';
import '../data/models/admin.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _service;
  
  // State management
  Admin? _admin;
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _hotels = [];
  List<String> _payments = [];
  bool _isLoading = false;
  String? _error;

  AdminProvider(this._service);

  // Getters
  Admin? get admin => _admin;
  List<Map<String, dynamic>> get bookings => List.unmodifiable(_bookings);
  List<Map<String, dynamic>> get hotels => List.unmodifiable(_hotels);
  List<String> get payments => List.unmodifiable(_payments);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Centralized state handler
  Future<void> _handleOperation(Future<void> Function() operation) async {
    try {
      _setLoading(true);
      await operation();
    } catch (e) {
      _setError('Operation failed: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool state) {
    _isLoading = state;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  // Core operations
  Future<void> fetchAdmin(String adminId) => _handleOperation(() async {
    _admin = await _service.getAdmin(adminId);
  });

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
  });

  Future<void> approveRoom(String roomId) => _handleOperation(() async {
    await _service.approveRoom(roomId);
    await _refreshHotels();
  });

  Future<void> rejectRoom(String roomId) => _handleOperation(() async {
    await _service.rejectRoom(roomId);
    await _refreshHotels();
  });

  Future<void> updatePermissions(List<String> newPermissions) => _handleOperation(() async {
    if (_admin == null) return;
    
    await _service.updateAdminPermissions(
      adminId: _admin!.id,
      managedHotels: newPermissions,
    );
    
    _admin = _admin!.copyWith(permissions: newPermissions);
  });

  Future<void> addPayment(String payment) => _handleOperation(() async {
    await _service.addPayment(payment);
    _payments = [..._payments, payment];
  });

  // Helper methods
  bool canManageHotel(String hotelId) {
    return _admin != null && _admin!.managesHotel(hotelId);
  }

  Future<void> _refreshHotels() async {
    _hotels = await _service.getHotelListings();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}