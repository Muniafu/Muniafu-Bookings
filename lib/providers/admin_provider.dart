import 'package:flutter/material.dart';
import '../data/services/admin_service.dart';
import '../data/models/admin.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService;
  Admin? _admin;
  List<String> _payments = [];
  bool _isLoading = false;
  String? _error;

  AdminProvider(this._adminService);

  // Getters
  Admin? get admin => _admin;
  List<String> get payments => List.unmodifiable(_payments); // Return unmodifiable list
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch admin details
  Future<void> fetchAdmin(String adminId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _admin = await _adminService.getAdmin(adminId); // Changed from getAdminById to getAdmin
    } catch (e) {
      _error = 'Failed to load admin data: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if admin can manage a specific hotel
  bool canManageHotel(String hotelId) { // Changed from async to sync since we have the data locally
    if (_admin == null) {
      return false;
    }
    return _admin!.managesHotel(hotelId);
  }

  Future<void> updatePermissions(List<String> newPermissions) async {
  if (_admin == null) return;
  
  try {
    _isLoading = true;
    notifyListeners();
    
    await _adminService.updateAdminPermissions(
      adminId: _admin!.id,
      managedHotels: newPermissions,
    );
    
    _admin = _admin!.copyWith(permissions: newPermissions);
  } catch (e) {
    _error = 'Failed to update permissions: ${e.toString()}';
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // Fetch payments
  Future<void> fetchPayments() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // First try to fetch from service
      _payments = await _adminService.fetchPayments();
      
      // Fallback to demo data if empty (for development)
      if (_payments.isEmpty) {
        _payments = _getDemoPayments();
      }
    } catch (e) {
      _error = 'Failed to load payments: ${e.toString()}';
      _payments = _getDemoPayments(); // Fallback
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a payment
  Future<void> addPayment(String payment) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _adminService.addPayment(payment);
      _payments = [..._payments, payment]; // Create new list instead of modifying
    } catch (e) {
      _error = 'Failed to add payment: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Demo payments data
  List<String> _getDemoPayments() {
    return ['Payment 1', 'Payment 2', 'Payment 3'];
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}