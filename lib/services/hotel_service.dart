import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel_model.dart';
import '../models/room_model.dart';

class HotelService {
  final CollectionReference<Map<String, dynamic>> _hotels = FirebaseFirestore.instance.collection('hotels').withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data() ?? <String, dynamic>{},
        toFirestore: (m, _) => m,
      );

  Future<void> addHotel(HotelModel hotel) async {
    await _hotels.doc(hotel.id).set(hotel.toMap());
  }

  Future<void> updateHotel(HotelModel hotel) async {
    await _hotels.doc(hotel.id).update(hotel.toMap());
  }

  Future<void> deleteHotel(String id) async {
    await _hotels.doc(id).delete();
  }

  /// Paginated query; provider handles startAfterDocument
  Future<QuerySnapshot<Map<String, dynamic>>> getHotelsPaginated({
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int limit = 10,
    String? searchQuery,
  }) async {
    Query<Map<String, dynamic>> q = _hotels;
    // order by rating descending for relevance
    q = q.orderBy('rating', descending: true).limit(limit);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final qText = searchQuery.trim();
      // naive text filter - Firestore string range trick
      q = q.where('name', isGreaterThanOrEqualTo: qText).where('name', isLessThanOrEqualTo: '$qText\uf8ff');
    }

    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }

    return q.get();
  }

  Future<HotelModel?> getHotelById(String id) async {
    final doc = await _hotels.doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return HotelModel.fromMap(data, id: doc.id);
  }

  Future<List<RoomModel>> getRoomsByHotel(String hotelId) async {
    // demo/mock data - ideally call Firebase: collection('rooms').where('hotelId', isEqualTo: hotelId)
    return [
      RoomModel(
        id: 'room1',
        hotelId: hotelId,
        type: 'Deluxe Suite',
        capacity: 2,
        features: ['Wifi', 'TV', 'Mini Bar'],
        amenities: ['AC', 'Parking'],
        images: ['https://via.placeholder.com/400x200.png?text=Deluxe'],
        size: 350, pricePerNight: 0, description: '', name: '',
      ),
      RoomModel(
        id: 'room2',
        hotelId: hotelId,
        type: 'Standard Room',
        capacity: 2,
        features: ['WiFi', 'TV'],
        amenities: ['Balcony'],
        images: ['https://via.placeholder.com/400x200.png?text=Standard'],
        size: 220, pricePerNight: 0, description: '', name: '',
      ),
    ];
  }
}