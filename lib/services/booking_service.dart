import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  final _bookings = FirebaseFirestore.instance.collection('bookings');

  Future<double> calculateTotalPrice({
    required double basePrice,
    required double taxRate,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    final days = checkOut.difference(checkIn).inDays;
    final subtotal = basePrice * days;
    return subtotal + (subtotal * taxRate);
  }

  Future<List<BookingModel>> getBookingsByDateRange(
    String hotelId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _bookings.where('hotelId', isEqualTo: hotelId).where('checkIn', isGreaterThanOrEqualTo: start).where('checkOut', isLessThanOrEqualTo: end).get();

    return snapshot.docs.map((doc) => BookingModel.fromMap(doc.data())).toList();
  }

  Future<void> createBooking(BookingModel booking) async {
    await _bookings.doc(booking.id).set(booking.toMap());
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    final snapshot = await _bookings.where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => BookingModel.fromMap(doc.data())).toList();
  }

  Future<void> cancelBooking(String bookingId) async {
    await _bookings.doc(bookingId).update({'status': 'cancelled'});
  }

  Future<void> updateBooking(BookingModel booking) async {
    await _bookings.doc(booking.id).update(booking.toMap());
  }

  Future<bool> isRoomAvailable(String roomId, DateTime checkIn, DateTime checkOut) async {
    final snapshot = await _bookings
        .where('roomId', isEqualTo: roomId)
        .where('status', isEqualTo: 'confirmed')
        .get();

    for (var doc in snapshot.docs) {
      final booking = BookingModel.fromMap(doc.data());
      final overlap = checkIn.isBefore(booking.checkOut) && checkOut.isAfter(booking.checkIn);
      if (overlap) return false;
    }
    return true;
  }
}