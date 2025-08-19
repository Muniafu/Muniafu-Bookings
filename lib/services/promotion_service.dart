import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionService {
  final _promotions = FirebaseFirestore.instance.collection('promotions');

  Future<void> createPromotion(Map<String, dynamic> promo) async {
    await _promotions.add(promo);
  }

  Future<List<Map<String, dynamic>>> getPromotions() async {
    final snapshot = await _promotions.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}