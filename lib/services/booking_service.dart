import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final CollectionReference bookingCollection =  FirebaseFirestore.instance.collection('booking');

  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    try {
      await bookingCollection.add(bookingData);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBookingsByUserId(String userId) async {
    try {
      QuerySnapshot snapshot = await bookingCollection
        .where('userId, isEqualTo: userId')
        .get();
      return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    } catch (e) {
      throw Exception('Failed to get bookings: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      QuerySnapshot snapshot = await bookingCollection.get();
      return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    } catch (e) {
      throw Exception('Failed to get all bookings: $e');
    }
  }
}