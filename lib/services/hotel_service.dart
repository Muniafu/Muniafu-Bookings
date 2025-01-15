import 'package:cloud_firestore/cloud_firestore.dart';

class HotelService {
  final CollectionReference hotelCollection = FirebaseFirestore.instance.collection('hotels');

  Future<void> addHotel(Map<String, dynamic> hotelData) async {
    try {
      await hotelCollection.add(hotelData);
    } catch (e) {
      throw Exception('Failed to add hotel: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllHotels() async {
    try {
      QuerySnapshot snapshot = await hotelCollection.get();
      return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
    } catch (e) {
      throw Exception('Failed to get hotels $e');      
    }
  }

  Future<Map<String, dynamic>?> getHotelById(String id) async {
    try {
      DocumentSnapshot snapshot = await hotelCollection.doc(id).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      throw Exception('Failed to get hotel $e');
    }
    return null;
  }
}