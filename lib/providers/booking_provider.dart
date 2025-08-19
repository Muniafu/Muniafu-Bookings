import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> loadBookings(String userId) async {
    _isLoading = true;
    notifyListeners();
    _bookings = await _bookingService.getUserBookings(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createBooking(BookingModel booking) async {
    await _bookingService.createBooking(booking);
    _bookings.add(booking);
    notifyListeners();
  }

  Future<void> updateBooking(BookingModel updatedBooking, Map<String, dynamic> changes) async {
    await _bookingService.updateBooking(updatedBooking);
    final index = _bookings.indexWhere((b) => b.id == updatedBooking.id);
    if (index != -1) {
      _bookings[index] = updatedBooking;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    await _bookingService.cancelBooking(bookingId);
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index] = BookingModel(
        id: _bookings[index].id,
        userId: _bookings[index].userId,
        roomId: _bookings[index].roomId,
        checkIn: _bookings[index].checkIn,
        checkOut: _bookings[index].checkOut,
        guests: _bookings[index].guests,
        totalPrice: _bookings[index].totalPrice,
        status: 'cancelled',
        paymentId: _bookings[index].paymentId,
      );
      notifyListeners();
    }
  }
}