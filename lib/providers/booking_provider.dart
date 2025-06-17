import 'package:flutter/material.dart';
import '../data/models/booking.dart';
import '../data/services/booking_service.dart';

class BookingProvider with ChangeNotifier {
  final BookingService _bookingService;
  final String? userId;

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  
  List<Booking> get activeBookings => _bookings.where((b) => b.isActive).toList();
  List<Booking> get pastBookings => _bookings.where((b) => 
      b.status == BookingStatus.completed || 
      b.status == BookingStatus.cancelled).toList();
  List<Booking> get upcomingBookings => _bookings.where((b) => 
      b.status == BookingStatus.confirmed && 
      b.checkInDate.isAfter(DateTime.now())).toList();

  BookingProvider(this._bookingService, {this.userId});

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

  // UPDATED: Create booking with payment verification
  Future<String> createBooking(Booking booking) async {
    try {
      _setLoading(true);
      _clearMessages();
      
      String bookingId;
      
      if (_bookingService.isFirestoreMode) {
        // Use model-based creation for Firestore
        bookingId = await _bookingService.createBookingWithModel(booking);
      } else {
        // For HTTP mode, use JSON creation
        bookingId = await _bookingService.createBooking(booking.toJson());
      }
      
      // Update booking with server-generated ID
      final confirmedBooking = booking.copyWith(id: bookingId);
      _bookings.add(confirmedBooking);
      
      _successMessage = 'Booking successful!';
      return bookingId;
    } catch (e) {
      _error = 'Failed to create booking: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // NEW: Confirm booking after payment
  Future<void> confirmBooking(String bookingId) async {
    try {
      _setLoading(true);
      _clearMessages();
      
      await _bookingService.updateBookingStatus(
        bookingId, 
        BookingStatus.confirmed.name
      );
      
      // Update local booking status
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: BookingStatus.confirmed
        );
      }
      
      _successMessage = 'Booking confirmed!';
    } catch (e) {
      _error = 'Failed to confirm booking: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // UPDATED: Cancel booking with status check
  Future<void> cancelBooking(String bookingId) async {
    try {
      _setLoading(true);
      _clearMessages();
      
      final booking = _bookings.firstWhere((b) => b.id == bookingId);
      
      // Prevent cancelling already completed bookings
      if (booking.status == BookingStatus.completed) {
        throw Exception('Cannot cancel completed bookings');
      }
      
      await _bookingService.cancelBooking(bookingId);
      
      // Update status instead of removing
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          status: BookingStatus.cancelled
        );
      }
      
      _successMessage = 'Booking cancelled successfully';
    } catch (e) {
      _error = 'Failed to cancel booking: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ... rest of the methods remain the same ...

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearMessages() {
    _error = null;
    _successMessage = null;
  }
}