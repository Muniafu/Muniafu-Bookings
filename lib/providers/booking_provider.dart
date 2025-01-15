import 'package:flutter/material.dart';

// Managing booking-related actions
class BookingProvider  with ChangeNotifier{
  List<String> _bookings = [];

  List<String> get bookings => _bookings;

  // Add a new booking
  void addBooking(String booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  //  Fetch bookings (simulate API call)
  Future<void> fetchBookings() async {
    await Future.delayed(const Duration(seconds: 5));
    _bookings = ['Booking 1', 'Booking 2', 'Booking 3'];
    notifyListeners();
  }
}