import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> create(String path, Map<String, dynamic> data) async {
    await _db.doc(path).set(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> get(String path) async {
    return await _db.doc(path).get();
  }

  Future<void> update(String path, Map<String, dynamic> data) async {
    await _db.doc(path).update(data);
  }

  Future<void> delete(String path) async {
    await _db.doc(path).delete();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> stream(String path) {
    return _db.doc(path).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream(String path) {
    return _db.collection(path).snapshots();
  }
}