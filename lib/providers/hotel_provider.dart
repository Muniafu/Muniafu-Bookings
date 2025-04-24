import 'package:flutter/material.dart';
import '../data/services/hotel_service.dart';
import '../data/models/hotel.dart';

class HotelProvider with ChangeNotifier {
  final HotelService _hotelService;
  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _error;

  HotelProvider(this._hotelService);

  // Getters
  List<Hotel> get hotels => _hotels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all hotels
  Future<void> fetchHotels() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _hotels = await _hotelService.fetchHotels();
    } catch (e) {
      _error = 'Failed to load hotels: ${e.toString()}';
      // Fallback to demo data if API fails (remove in production)
      _hotels = _getDemoHotels();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new hotel
  Future<void> addHotel(Hotel hotel) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newHotel = await _hotelService.addHotel(hotel as Map<String, dynamic>);
      _hotels.add(newHotel as Hotel);
    } catch (e) {
      _error = 'Failed to add hotel: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a hotel
  Future<void> deleteHotel(String hotelId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _hotelService.deleteHotel(hotelId);
      _hotels.removeWhere((hotel) => hotel.id == hotelId);
    } catch (e) {
      _error = 'Failed to delete hotel: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search hotels by name
  List<Hotel> searchHotels(String query) {
    return _hotels.where((hotel) => 
      hotel.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Demo data fallback (from second implementation)
  List<Hotel> _getDemoHotels() {
    return [
      Hotel(
        id: '1',
        name: 'Hotel Paradise',
        location: 'Beachfront',
        description: 'A beautiful paradise hotel by the beach.',
        images: ['https://example.com/hotel1.jpg'],
      ),
      Hotel(
        id: '2',
        name: 'Ocean View Resort',
        location: 'Cliffside',
        description: 'Resort with stunning ocean views.',
        images: ['https://example.com/hotel2.jpg'],
      ),
      Hotel(
        id: '3',
        name: 'Mountain Retreat',
        location: 'Alpine',
        description: 'A peaceful retreat in the mountains.',
        images: ['https://example.com/hotel3.jpg'],
      ),
      Hotel(
        id: '4',
        name: 'City Lights Hotel',
        location: 'Downtown',
        description: 'Experience the city life at City Lights Hotel.',
        images: ['https://example.com/hotel4.jpg'],
      ),
      Hotel(
        id: '5',
        name: 'Cozy Star Inn',
        location: 'Suburbs',
        description: 'A cozy inn for a relaxing stay.',
        images: ['https://example.com/hotel5.jpg'],
      ),
      Hotel(
        id: '6',
        name: 'Hot Water Springs',
        location: 'Valley',
        description: 'Enjoy natural hot springs in the valley.',
        images: ['https://example.com/hotel6.jpg'],
      ),
    ];
  }
}