import 'package:flutter/material.dart';

// Manage hotel-related actions
class HotelProvider with ChangeNotifier{
  List<String> _hotels = [];

  List<String> get hotels => _hotels;

  // Fetch a list of hotels (Simulate API calls)
  Future<void> fetchHotels() async {
    await Future.delayed(const Duration(seconds: 5));
    _hotels = ['Hotel Paradise','Ocean View Resort','Mountain Retreat', 'City Lights Hotel', 'Cozy Star Inn', 'Hot Water Springs'];
    notifyListeners();
  }

  // Add new hotel (Admin action)
  void addHotel(String hotel) {
    _hotels.add(hotel);
    notifyListeners();
  }
}