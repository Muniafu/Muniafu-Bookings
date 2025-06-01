import 'package:flutter/material.dart';
import '../data/models/booking.dart';
import '../data/services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService;
  final String? userId; // Optional for non-user specific operations

  // State properties
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Getters
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  
  // Filtered bookings
  List<Booking> get activeBookings => _bookings.where((b) => b.isActive).toList();
  List<Booking> get pastBookings => _bookings.where((b) => 
      b.status == BookingStatus.completed || 
      b.status == BookingStatus.cancelled).toList();
  List<Booking> get upcomingBookings => _bookings.where((b) => 
      b.status == BookingStatus.confirmed && 
      b.checkInDate.isAfter(DateTime.now())).toList();

  BookingProvider(this._bookingService, {this.userId});

  // Load user bookings
  Future<void> loadBookings() async {
    if (userId == null) return;
    
    try {
      _setLoading(true);
      _clearMessages();
      
      _bookings = await _bookingService.getUserBookings(userId!);
    } catch (e) {
      _error = 'Failed to load bookings: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Create a new booking
  Future<void> createBooking(Booking booking) async {
    try {
      _setLoading(true);
      _clearMessages();
      
      if (_bookingService.isFirestoreMode) {
        await _bookingService.createBookingWithModel(booking);
      } else {
        await _bookingService.createBooking(booking.toJson());
      }
      
      _bookings.add(booking);
      _successMessage = 'Booking successful!';
    } catch (e) {
      _error = 'Failed to create booking: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      _setLoading(true);
      _clearMessages();
      
      await _bookingService.cancelBooking(bookingId);
      _bookings.removeWhere((b) => b.id == bookingId);
      _successMessage = 'Booking cancelled successfully';
    } catch (e) {
      _error = 'Failed to cancel booking: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Reschedule a booking
  Future<void> rescheduleBooking(
    String bookingId,
    DateTime newCheckIn,
    DateTime newCheckOut,
  ) async {
    try {
      _setLoading(true);
      _clearMessages();
      
      await _bookingService.rescheduleBooking(bookingId, newCheckIn, newCheckOut);
      
      // Update local booking
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          checkInDate: newCheckIn,
          checkOutDate: newCheckOut,
        );
      }
      
      _successMessage = 'Booking rescheduled successfully';
    } catch (e) {
      _error = 'Failed to reschedule booking: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Clear messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearMessages() {
    _error = null;
    _successMessage = null;
  }
}