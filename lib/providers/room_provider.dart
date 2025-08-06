import 'package:flutter/material.dart';
import '../data/models/room.dart';
import '../data/services/room_service.dart';

class RoomProvider with ChangeNotifier {
  final RoomService _roomService = RoomService();
  List<Room> _rooms = [];
  bool _loading = false;

  List<Room> get rooms => _rooms;
  bool get isLoading => _loading;

  Future<void> loadRooms(String hotelId) async {
    _setLoading(true);
    _rooms = await _roomService.fetchRoomsByHotel(hotelId);
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}