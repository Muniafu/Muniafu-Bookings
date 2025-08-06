import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room.dart';

class RoomService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Room>> fetchRoomsByHotel(String hotelId) async {
    final query = await _db
        .collection('rooms')
        .where('hotelId', isEqualTo: hotelId)
        .get();

    return query.docs.map((doc) => Room.fromFirestore(doc)).toList();
  }
}