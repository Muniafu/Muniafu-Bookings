import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/booking.dart';

class BookingService {
  final String? _baseUrl;
  final CollectionReference? _bookingCollection;

  BookingService._({String? baseUrl, CollectionReference? bookingCollection})
      : _baseUrl = baseUrl,
        _bookingCollection = bookingCollection;

  factory BookingService.http(String baseUrl) {
    return BookingService._(baseUrl: baseUrl);
  }

  factory BookingService.firestore() {
    return BookingService._(
      bookingCollection: FirebaseFirestore.instance.collection('bookings'),
    );
  }

  // Mode detection
  bool get isHttpMode => _baseUrl != null;
  bool get isFirestoreMode => _bookingCollection != null;

  // Common operations
  Future<List<Booking>> getUserBookings(String userId) async {
    if (isHttpMode) {
      return _fetchHttpBookings(userId);
    } else if (isFirestoreMode) {
      return _fetchFirestoreBookings(userId);
    }
    throw _unsupportedError('getUserBookings');
  }

  Future<String> createBooking(Map<String, dynamic> bookingData) async {
    if (isFirestoreMode) {
      return _createFirestoreBooking(bookingData);
    }
    throw _unsupportedError('createBooking');
  }

  Future<void> createBookingWithModel(Booking booking) async {
    if (isFirestoreMode) {
      return _createFirestoreBookingWithModel(booking);
    }
    throw _unsupportedError('createBookingWithModel');
  }

  Future<void> cancelBooking(String bookingId) async {
    if (isHttpMode) {
      return _cancelHttpBooking(bookingId);
    } else if (isFirestoreMode) {
      return _cancelFirestoreBooking(bookingId);
    }
    throw _unsupportedError('cancelBooking');
  }

  // HTTP-specific operations
  Future<void> _createHttpBooking(Map<String, dynamic> payload) async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/bookings'),
        body: jsonEncode(payload),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (res.statusCode != 200 && res.statusCode != 201) {
        throw BookingServiceException(
            'Failed to create booking: ${res.statusCode}');
      }
    } catch (e) {
      throw BookingServiceException('HTTP create failed: ${e.toString()}');
    }
  }

  Future<List<Booking>> _fetchHttpBookings(String userId) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/bookings?user=$userId'));
      if (res.statusCode != 200) {
        throw BookingServiceException(
            'Request failed with status: ${res.statusCode}');
      }
      final data = json.decode(res.body) as List;
      return data.map((e) => Booking.fromJson(e)).toList();
    } catch (e) {
      throw BookingServiceException('Failed to fetch bookings: ${e.toString()}');
    }
  }

  Future<void> _cancelHttpBooking(String bookingId) async {
    try {
      final res = await http.delete(
        Uri.parse('$_baseUrl/bookings/$bookingId/cancel'),
      );
      if (res.statusCode != 200) {
        throw BookingServiceException(
            'Cancel failed with status: ${res.statusCode}');
      }
    } catch (e) {
      throw BookingServiceException('HTTP cancel failed: ${e.toString()}');
    }
  }

  Future<void> rescheduleBooking(
    String bookingId,
    DateTime newCheckIn,
    DateTime newCheckOut,
  ) async {
    if (isHttpMode) {
      return _rescheduleHttpBooking(bookingId, newCheckIn, newCheckOut);
    } else if (isFirestoreMode) {
      return _rescheduleFirestoreBooking(bookingId, newCheckIn, newCheckOut);
    }
    throw _unsupportedError('rescheduleBooking');
  }

  Future<void> _rescheduleHttpBooking(
    String bookingId,
    DateTime newCheckIn,
    DateTime newCheckOut,
  ) async {
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/bookings/$bookingId/reschedule'),
        body: jsonEncode({
          'check_in': newCheckIn.toIso8601String(),
          'check_out': newCheckOut.toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (res.statusCode != 200) {
        throw BookingServiceException(
            'Reschedule failed with status: ${res.statusCode}');
      }
    } catch (e) {
      throw BookingServiceException('HTTP reschedule failed: ${e.toString()}');
    }
  }

  // Firestore-specific operations
  Future<String> _createFirestoreBooking(Map<String, dynamic> bookingData) async {
    try {
      final DocumentReference docRef = 
          await _bookingCollection!.add(bookingData);
      return docRef.id;
    } catch (e) {
      throw BookingServiceException('Firestore create failed: ${e.toString()}');
    }
  }

  Future<void> _createFirestoreBookingWithModel(Booking booking) async {
    try {
      await _bookingCollection!.doc(booking.id).set(booking.toFirestore());
    } catch (e) {
      throw BookingServiceException('Firestore model create failed: ${e.toString()}');
    }
  }

  Future<List<Booking>> _fetchFirestoreBookings(String userId) async {
    try {
      final QuerySnapshot snapshot = await _bookingCollection!
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => Booking.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw BookingServiceException('Failed to fetch user bookings: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getBookingsByUserId(String userId) async {
    if (isFirestoreMode) {
      return _getFirestoreBookingsByUserId(userId);
    }
    throw _unsupportedError('getBookingsByUserId');
  }

  Future<List<Map<String, dynamic>>> _getFirestoreBookingsByUserId(String userId) async {
    try {
      final QuerySnapshot snapshot = await _bookingCollection!
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw BookingServiceException('Failed to get user bookings: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    if (isFirestoreMode) {
      return _getAllFirestoreBookings();
    }
    throw _unsupportedError('getAllBookings');
  }

  Future<List<Map<String, dynamic>>> _getAllFirestoreBookings() async {
    try {
      final QuerySnapshot snapshot = await _bookingCollection!.get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw BookingServiceException('Failed to get all bookings: ${e.toString()}');
    }
  }

  Future<void> _cancelFirestoreBooking(String bookingId) async {
    try {
      await _bookingCollection!.doc(bookingId).delete();
    } catch (e) {
      throw BookingServiceException('Firestore cancel failed: ${e.toString()}');
    }
  }

  Future<void> _rescheduleFirestoreBooking(
    String bookingId,
    DateTime newCheckIn,
    DateTime newCheckOut,
  ) async {
    try {
      await _bookingCollection!.doc(bookingId).update({
        'checkInDate': Timestamp.fromDate(newCheckIn),
        'checkOutDate': Timestamp.fromDate(newCheckOut),
      });
    } catch (e) {
      throw BookingServiceException('Firestore reschedule failed: ${e.toString()}');
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    if (isFirestoreMode) {
      return _updateFirestoreBookingStatus(bookingId, status);
    }
    throw _unsupportedError('updateBookingStatus');
  }

  Future<void> _updateFirestoreBookingStatus(String bookingId, String status) async {
    try {
      await _bookingCollection!.doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw BookingServiceException('Failed to update booking status: ${e.toString()}');
    }
  }

  // Helper methods
  bool isValidBooking(DateTime checkIn, DateTime checkOut) {
    return checkOut.isAfter(checkIn) && 
           checkIn.isAfter(DateTime.now().subtract(const Duration(days: 1)));
  }

  UnsupportedError _unsupportedError(String method) => UnsupportedError(
      '$method is not supported in ${isHttpMode ? 'HTTP' : 'Firestore'} mode');
}

class BookingServiceException implements Exception {
  final String message;
  BookingServiceException(this.message);

  @override
  String toString() => 'BookingServiceException: $message';
}