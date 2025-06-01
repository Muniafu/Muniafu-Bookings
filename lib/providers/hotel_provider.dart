import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/hotel.dart';
import '../data/models/room.dart';
import 'package:muniafu/data/services/hotel_service.dart';

class HotelProvider extends ChangeNotifier {
  final HotelService _hotelService;
  
  // State properties
  List<Hotel> _allHotels = [];
  List<Hotel> _displayedHotels = [];
  List<Room> _rooms = [];
  String _searchQuery = '';
  Timer? _debounce;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Hotel> get hotels => _displayedHotels;
  List<Room> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  HotelProvider(this._hotelService);

  // Load all hotels with error handling
  Future<void> loadHotels() async {
    try {
      _setLoading(true);
      _error = null;
      
      _allHotels = await _hotelService.fetchHotels();
      _applySearchFilter();  // Re-apply existing search filter
    } catch (e) {
      _error = 'Failed to load hotels: ${e.toString()}';
      _allHotels = _getDemoHotels();
      _applySearchFilter();
    } finally {
      _setLoading(false);
    }
  }

  // Search hotels with debounce and fallback
  void searchHotels(String query) {
    _searchQuery = query;
    
    // Cancel previous debounce timer
    _debounce?.cancel();
    
    // Set up new debounce timer
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery.isEmpty) {
        _applySearchFilter();
        return;
      }

      try {
        // Attempt remote search
        _setLoading(true);
        _hotelService.searchHotels(_searchQuery).then((results) {
          _displayedHotels = results;
          notifyListeners();
        }).catchError((e) {
          // Fallback to local search if remote fails
          _applySearchFilter();
        }).whenComplete(() => _setLoading(false));
      } catch (e) {
        // Fallback to local search on error
        _applySearchFilter();
        _setLoading(false);
      }
    });
  }

  // Load rooms for a specific hotel
  Future<void> loadRooms(String hotelId) async {
    try {
      _setLoading(true);
      _error = null;
      
      _rooms = await _hotelService.fetchRooms(hotelId);
    } catch (e) {
      _error = 'Failed to load rooms: ${e.toString()}';
      _rooms = [];
    } finally {
      _setLoading(false);
    }
  }

  // Save hotel (create or update)
  Future<void> saveHotel(Hotel hotel) async {
    try {
      _setLoading(true);
      _error = null;
      
      if (hotel.id.isEmpty) {
        // New hotel - add to Firestore
        await _hotelService.addHotel(hotel.toJson());
      } else {
        // Existing hotel - update
        await _hotelService.updateHotel(hotel);
      }
      
      await loadHotels();  // Refresh hotel list
    } catch (e) {
      _error = 'Failed to save hotel: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a hotel
  Future<void> deleteHotel(String hotelId) async {
    try {
      _setLoading(true);
      _error = null;
      
      await _hotelService.deleteHotel(hotelId);
      await loadHotels();  // Refresh hotel list
    } catch (e) {
      _error = 'Failed to delete hotel: ${e.toString()}';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Apply search filter locally
  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _displayedHotels = _allHotels;
    } else {
      _displayedHotels = _allHotels.where((hotel) => 
        hotel.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (hotel.location.toLowerCase().contains(_searchQuery.toLowerCase())) ||
        (hotel.description.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }
    notifyListeners();
  }

  // Demo data fallback
  List<Hotel> _getDemoHotels() {
    return [
      Hotel(
        id: '1',
        name: 'Hotel Paradise',
        location: 'Beachfront',
        description: 'A beautiful paradise hotel by the beach.',
        images: ['https://example.com/hotel1.jpg'],
        amenities: ['WiFi', 'Pool', 'Spa'],
        rating: 4.5,
        pricePerNight: 200,
      ),
      Hotel(
        id: '2',
        name: 'Ocean View Resort',
        location: 'Cliffside',
        description: 'Resort with stunning ocean views.',
        images: ['https://example.com/hotel2.jpg'],
        amenities: ['WiFi', 'Restaurant', 'Gym'],
        rating: 4.0,
        pricePerNight: 180,
      ),
      // Add other demo hotels as needed
    ];
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}