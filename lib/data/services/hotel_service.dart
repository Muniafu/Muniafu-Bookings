import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muniafu/data/models/hotel.dart';

class HotelService {
  final CollectionReference _hotelCollection = 
      FirebaseFirestore.instance.collection('hotels');

  /// Fetches all hotels as HotelModel objects
  Future<List<Hotel>> fetchHotels() async {
    try {
      final QuerySnapshot snapshot = await _hotelCollection.get();
      return snapshot.docs
          .map((doc) => Hotel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw HotelServiceException('Failed to fetch hotels: ${e.toString()}');
    }
  }

  /// Gets all hotels as raw Map data
  Future<List<Map<String, dynamic>>> getAllHotels() async {
    try {
      final QuerySnapshot snapshot = await _hotelCollection.get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      throw HotelServiceException('Failed to get all hotels: ${e.toString()}');
    }
  }

  /// Adds a new hotel with automatic ID generation
  Future<String> addHotel(Map<String, dynamic> hotelData) async {
    try {
      final DocumentReference docRef = await _hotelCollection.add(hotelData);
      return docRef.id;
    } catch (e) {
      throw HotelServiceException('Failed to add hotel: ${e.toString()}');
    }
  }

  /// Creates a new hotel with a specific ID
  Future<void> createHotel(Hotel hotel) async {
    try {
      await _hotelCollection.doc(hotel.id).set(hotel.toJson());
    } catch (e) {
      throw HotelServiceException('Failed to create hotel: ${e.toString()}');
    }
  }

  /// Gets a specific hotel by ID as HotelModel
  Future<Hotel?> getHotel(String id) async {
    try {
      final DocumentSnapshot snapshot = await _hotelCollection.doc(id).get();
      if (snapshot.exists) {
        return Hotel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw HotelServiceException('Failed to get hotel: ${e.toString()}');
    }
  }

  /// Gets hotel data as raw Map
  Future<Map<String, dynamic>?> getHotelById(String id) async {
    try {
      final DocumentSnapshot snapshot = await _hotelCollection.doc(id).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw HotelServiceException('Failed to get hotel by ID: ${e.toString()}');
    }
  }

  /// Updates an existing hotel
  Future<void> updateHotel(Hotel hotel) async {
    try {
      await _hotelCollection.doc(hotel.id).update(hotel.toJson());
    } catch (e) {
      throw HotelServiceException('Failed to update hotel: ${e.toString()}');
    }
  }

  /// Updates specific fields of a hotel
  Future<void> updateHotelFields({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _hotelCollection.doc(id).update(updates);
    } catch (e) {
      throw HotelServiceException('Failed to update hotel fields: ${e.toString()}');
    }
  }

  /// Deletes a hotel by ID
  Future<void> deleteHotel(String hotelId) async {
    try {
      await _hotelCollection.doc(hotelId).delete();
    } catch (e) {
      throw HotelServiceException('Failed to delete hotel: ${e.toString()}');
    }
  }
}

class HotelServiceException implements Exception {
  final String message;
  HotelServiceException(this.message);

  @override
  String toString() => 'HotelServiceException: $message';
}