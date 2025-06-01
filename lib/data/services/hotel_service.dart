import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muniafu/data/models/hotel.dart';
import 'package:muniafu/data/models/room.dart';

class HotelService {
  final String? _baseUrl;
  final CollectionReference? _hotelCollection;

  HotelService._({String? baseUrl, CollectionReference? hotelCollection})
      : _baseUrl = baseUrl,
        _hotelCollection = hotelCollection;

  factory HotelService.http(String baseUrl) {
    return HotelService._(baseUrl: baseUrl);
  }

  factory HotelService.firestore() {
    return HotelService._(
      hotelCollection: FirebaseFirestore.instance.collection('hotels'),
    );
  }

  // Common properties
  bool get isHttpMode => _baseUrl != null;
  bool get isFirestoreMode => _hotelCollection != null;

  // HTTP Operations
  Future<List<Hotel>> _fetchHttpHotels(String endpoint) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl$endpoint'));
      if (res.statusCode != 200) {
        throw HotelServiceException(
            'Request failed with status: ${res.statusCode}');
      }
      final data = json.decode(res.body) as List;
      return data.map((json) => Hotel.fromJson(json)).toList();
    } catch (e) {
      throw HotelServiceException('HTTP operation failed: ${e.toString()}');
    }
  }

  Future<List<Room>> _fetchHttpRooms(String hotelId) async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/hotels/$hotelId/rooms'));
      if (res.statusCode != 200) {
        throw HotelServiceException(
            'Request failed with status: ${res.statusCode}');
      }
      final data = json.decode(res.body) as List;
      return data.map((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw HotelServiceException('Failed to fetch rooms: ${e.toString()}');
    }
  }

  // Firestore Operations
  Future<List<Hotel>> _fetchFirestoreHotels() async {
    try {
      final QuerySnapshot snapshot = await _hotelCollection!.get();
      return snapshot.docs
          .map((doc) => Hotel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw HotelServiceException('Failed to fetch hotels: ${e.toString()}');
    }
  }

  // Unified Interface
  Future<List<Hotel>> fetchHotels() async {
    if (isHttpMode) return _fetchHttpHotels('/hotels');
    if (isFirestoreMode) return _fetchFirestoreHotels();
    throw _unsupportedError('fetchHotels');
  }

  Future<List<Hotel>> searchHotels(String query) async {
    if (isHttpMode) {
      return _fetchHttpHotels('/hotels/search?q=$query');
    }
    throw _unsupportedError('searchHotels');
  }

  Future<List<Room>> fetchRooms(String hotelId) async {
    if (isHttpMode) return _fetchHttpRooms(hotelId);
    throw _unsupportedError('fetchRooms');
  }

  Future<List<Map<String, dynamic>>> getAllHotels() async {
    if (isFirestoreMode) {
      try {
        final QuerySnapshot snapshot = await _hotelCollection!.get();
        return snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      } catch (e) {
        throw HotelServiceException('Failed to get all hotels: ${e.toString()}');
      }
    }
    throw _unsupportedError('getAllHotels');
  }

  Future<String> addHotel(Map<String, dynamic> hotelData) async {
    if (isFirestoreMode) {
      try {
        final DocumentReference docRef = await _hotelCollection!.add(hotelData);
        return docRef.id;
      } catch (e) {
        throw HotelServiceException('Failed to add hotel: ${e.toString()}');
      }
    }
    throw _unsupportedError('addHotel');
  }

  Future<void> createHotel(Hotel hotel) async {
    if (isFirestoreMode) {
      try {
        await _hotelCollection!.doc(hotel.id).set(hotel.toJson());
      } catch (e) {
        throw HotelServiceException('Failed to create hotel: ${e.toString()}');
      }
    } else {
      throw _unsupportedError('createHotel');
    }
  }

  Future<Hotel?> getHotel(String id) async {
    if (isFirestoreMode) {
      try {
        final DocumentSnapshot snapshot = await _hotelCollection!.doc(id).get();
        return snapshot.exists
            ? Hotel.fromJson(snapshot.data() as Map<String, dynamic>)
            : null;
      } catch (e) {
        throw HotelServiceException('Failed to get hotel: ${e.toString()}');
      }
    }
    throw _unsupportedError('getHotel');
  }

  Future<Map<String, dynamic>?> getHotelById(String id) async {
    if (isFirestoreMode) {
      try {
        final DocumentSnapshot snapshot = await _hotelCollection!.doc(id).get();
        return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
      } catch (e) {
        throw HotelServiceException(
            'Failed to get hotel by ID: ${e.toString()}');
      }
    }
    throw _unsupportedError('getHotelById');
  }

  Future<void> updateHotel(Hotel hotel) async {
    if (isFirestoreMode) {
      try {
        await _hotelCollection!.doc(hotel.id).update(hotel.toJson());
      } catch (e) {
        throw HotelServiceException('Failed to update hotel: ${e.toString()}');
      }
    } else {
      throw _unsupportedError('updateHotel');
    }
  }

  Future<void> updateHotelFields({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    if (isFirestoreMode) {
      try {
        await _hotelCollection!.doc(id).update(updates);
      } catch (e) {
        throw HotelServiceException(
            'Failed to update hotel fields: ${e.toString()}');
      }
    } else {
      throw _unsupportedError('updateHotelFields');
    }
  }

  Future<void> deleteHotel(String hotelId) async {
    if (isFirestoreMode) {
      try {
        await _hotelCollection!.doc(hotelId).delete();
      } catch (e) {
        throw HotelServiceException('Failed to delete hotel: ${e.toString()}');
      }
    } else {
      throw _unsupportedError('deleteHotel');
    }
  }

  // Helper methods
  UnsupportedError _unsupportedError(String method) => UnsupportedError(
      '$method is not supported in ${isHttpMode ? 'HTTP' : 'Firestore'} mode');

}

class HotelServiceException implements Exception {
  final String message;
  HotelServiceException(this.message);

  @override
  String toString() => 'HotelServiceException: $message';
}