import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/booking.dart';
import '../../data/models/room.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Creates a new booking with full details
  Future<String> createBooking({
    required String userId,
    required Room room,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
    required double totalAmount,
    List<String>? specialRequests,
    bool isMock = false,
  }) async {
    final bookingId = _uuid.v4();
    final booking = Booking(
      id: bookingId,
      userId: userId,
      hotelId: room.hotelId,
      hotelName: '',
      roomId: room.id,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      numberOfGuests: numberOfGuests,
      totalAmount: totalAmount,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
      specialRequests: specialRequests,
    );

    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .set(booking.toFirestore());

    return bookingId;
  }

  /// Gets bookings for a specific user with optional filters
  Future<List<Booking>> getBookingsForUser(
    String userId, {
    BookingStatus? status,
    bool activeOnly = false,
    bool pastOnly = false,
  }) async {
    Query query = _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('checkInDate', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    if (activeOnly) {
      query = query.where('checkOutDate', isGreaterThan: Timestamp.now());
    }

    if (pastOnly) {
      query = query.where('checkOutDate', isLessThan: Timestamp.now());
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
  }

  /// Creates a simplified booking (for testing/mock purposes)
  Future<String> createMockBooking({
    required String userId,
    required String roomId,
  }) async {
    return createBooking(
      userId: userId,
      room: Room(
        id: roomId,
        hotelId: 'mock_hotel',
        type: 'Mock Room',
        pricePerNight: 0,
        capacity: 1,
        isAvailable: true,
        amenities: [],
        images: [],
      ),
      checkInDate: DateTime.now(),
      checkOutDate: DateTime.now().add(const Duration(days: 1)),
      numberOfGuests: 1,
      totalAmount: 0,
      isMock: true,
    );
  }

  /// Saves an existing booking object to Firestore
  Future<void> saveBooking(Booking booking) async {
    await _firestore
        .collection('bookings')
        .doc(booking.id)
        .set(booking.toFirestore());
  }

  /// Stream of all bookings for a specific user
  Stream<List<Booking>> streamUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  /// Cancels a booking by updating its status
  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
      'cancelledAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Gets all active bookings for a user (confirmed and not yet checked out)
  Future<List<Booking>> getActiveBookings(String userId) async {
    return getBookingsForUser(
      userId,
      status: BookingStatus.confirmed,
      activeOnly: true,
    );
  }

  /// Gets all past bookings for a user (already checked out)
  Future<List<Booking>> getPastBookings(String userId) async {
    return getBookingsForUser(
      userId,
      pastOnly: true,
    );
  }

  /// Gets all bookings with optional filters (Admin only)
  Future<List<Booking>> getAllBookings({
    BookingStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? hotelId,
  }) async {
    Query query = _firestore
        .collection('bookings')
        .orderBy('checkInDate', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    if (startDate != null) {
      query = query.where('checkInDate', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('checkOutDate', isLessThanOrEqualTo: endDate);
    }

    if (hotelId != null) {
      query = query.where('hotelId', isEqualTo: hotelId);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
  }

  /// Stream of all bookings with optional filters (Admin only)
  Stream<List<Booking>> streamAllBookings({
    BookingStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? hotelId,
  }) {
    Query query = _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    if (startDate != null) {
      query = query.where('checkInDate', isGreaterThanOrEqualTo: startDate);
    }

    if (endDate != null) {
      query = query.where('checkOutDate', isLessThanOrEqualTo: endDate);
    }

    if (hotelId != null) {
      query = query.where('hotelId', isEqualTo: hotelId);
    }

    return query.snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  /// Gets a single booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    final doc = await _firestore.collection('bookings').doc(bookingId).get();
    return doc.exists ? Booking.fromFirestore(doc) : null;
  }

  /// Updates booking status
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status, {
    String? adminNote,
  }) async {
    final updateData = {
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (adminNote != null) {
      updateData['adminNote'] = adminNote;
    }

    await _firestore.collection('bookings').doc(bookingId).update(updateData);
  }

  /// Extended admin functions
  Future<List<Booking>> getBookingsByHotel(String hotelId) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('hotelId', isEqualTo: hotelId)
        .orderBy('checkInDate', descending: true)
        .get();

    return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
  }

  Future<List<Booking>> getBookingsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('checkInDate', isGreaterThanOrEqualTo: startDate)
        .where('checkOutDate', isLessThanOrEqualTo: endDate)
        .orderBy('checkInDate')
        .get();

    return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
  }

  Future<void> addAdminNote(String bookingId, String note) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'adminNotes': FieldValue.arrayUnion([note]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBookingDetails({
    required String bookingId,
    DateTime? newCheckIn,
    DateTime? newCheckOut,
    int? newGuests,
    double? newTotal,
    List<String>? specialRequests,
  }) async {
    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (newCheckIn != null) updateData['checkInDate'] = newCheckIn;
    if (newCheckOut != null) updateData['checkOutDate'] = newCheckOut;
    if (newGuests != null) updateData['numberOfGuests'] = newGuests;
    if (newTotal != null) updateData['totalAmount'] = newTotal;
    if (specialRequests != null) {
      updateData['specialRequests'] = specialRequests;
    }

    await _firestore.collection('bookings').doc(bookingId).update(updateData);
  }
}