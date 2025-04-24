import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class BookingService {
  final CollectionReference _bookingCollection = 
      FirebaseFirestore.instance.collection('bookings');

  /// Creates a new booking with automatic ID generation
  Future<String> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final DocumentReference docRef = await _bookingCollection.add(bookingData);
      return docRef.id;
    } catch (e) {
      throw BookingServiceException('Failed to create booking: ${e.toString()}');
    }
  }

  /// Creates a new booking with specified ID using BookingModel
  Future<void> createBookingWithModel(Booking booking) async {
    try {
      await _bookingCollection.doc(booking.id).set(booking.toJson());
    } catch (e) {
      throw BookingServiceException('Failed to create booking: ${e.toString()}');
    }
  }

  /// Gets all bookings for a specific user as BookingModel objects
  Future<List<Booking>> fetchBookingsByUser(String userId) async {
    try {
      final QuerySnapshot snapshot = await _bookingCollection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw BookingServiceException('Failed to fetch user bookings: ${e.toString()}');
    }
  }

  /// Gets all bookings for a specific user as raw Map data
  Future<List<Map<String, dynamic>>> getBookingsByUserId(String userId) async {
    try {
      final QuerySnapshot snapshot = await _bookingCollection
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw BookingServiceException('Failed to get user bookings: ${e.toString()}');
    }
  }

  /// Gets all bookings in the system
  Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      final QuerySnapshot snapshot = await _bookingCollection.get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw BookingServiceException('Failed to get all bookings: ${e.toString()}');
    }
  }

  /// Cancels/deletes a booking by ID
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _bookingCollection.doc(bookingId).delete();
    } catch (e) {
      throw BookingServiceException('Failed to cancel booking: ${e.toString()}');
    }
  }

  /// Validates booking dates
  bool isValidBooking(DateTime checkIn, DateTime checkOut) {
    return checkOut.isAfter(checkIn) && 
           checkIn.isAfter(DateTime.now().subtract(const Duration(days: 1)));
  }

  /// Updates booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _bookingCollection.doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw BookingServiceException('Failed to update booking status: ${e.toString()}');
    }
  }
}

class BookingServiceException implements Exception {
  final String message;
  BookingServiceException(this.message);

  @override
  String toString() => 'BookingServiceException: $message';
}