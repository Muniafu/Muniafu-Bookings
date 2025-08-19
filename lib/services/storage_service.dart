import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadHotelImage(String hotelId, File file) async {
    final ref = _storage.ref().child('hotels/$hotelId/${const Uuid().v4()}.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  static Future<String> uploadRoomImage(String roomId, File file) async {
    final ref = _storage.ref().child('rooms/$roomId/${const Uuid().v4()}.jpg');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}