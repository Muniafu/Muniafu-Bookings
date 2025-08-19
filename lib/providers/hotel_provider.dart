import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel_model.dart';
import '../models/room_model.dart';
import '../services/hotel_service.dart';

class HotelProvider extends ChangeNotifier {
  final HotelService _hotelService = HotelService();

  final Map<String, HotelModel> _hotelCache = {};
  final Map<String, List<RoomModel>> _roomCache = {};
  
  final List<Map<String, dynamic>> _bookings = [];

  final List<HotelModel> _hotels = [];
  List<HotelModel> get hotels => List.unmodifiable(_hotels);

  List<RoomModel> _rooms = [];
  List<RoomModel> get rooms => _rooms;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  final int _pageSize = 10;

  String _search = '';

  HotelProvider() {
    // initial load
    fetchHotels(refresh: true);
    _loadMockHotels();
  }

  Future<HotelModel?> getHotelById(String id, {bool forceRefresh = false}) async {
    if (!forceRefresh && _hotelCache.containsKey(id)) {
      return _hotelCache[id];
    }

    final hotel = await _hotelService.getHotelById(id);
    if (hotel != null) {
      _hotelCache[id] = hotel;
    }
    return hotel;
  }

  List<Map<String, dynamic>> get bookings => _bookings;

  void _loadMockHotels() {
    _hotels.clear();
    _hotels.addAll([
      HotelModel(
        id: '1',
        name: 'Grand Paradise Resort',
        address: '123 Beachfront Ave, Miami, FL',
        coordinates: {'lat': 25.7617, 'lng': -80.1918},
        description: 'Luxury beachfront resort with spa, pool, and fine dining.',
        amenities: ['Free WiFi', 'Swimming Pool', 'Spa', 'Restaurant'],
        images: [
          'https://picsum.photos/seed/hotel1/600/400',
          'https://picsum.photos/seed/hotel1a/600/400',
        ],
        rating: 4.8,
        isPopular: true,
        isNew: false,
        avgPrice: 350.0,
        basePrice: 300.0,
        taxRate: 0.12,
        seoTags: ['beachfront', 'luxury', 'resort'],
        availableRooms: 12,
        tags: ['Top Rated', 'Sea View'],
      ),
      HotelModel(
        id: '2',
        name: 'Urban City Hotel',
        address: '456 Downtown St, New York, NY',
        coordinates: {'lat': 40.7128, 'lng': -74.0060},
        description: 'Modern hotel in the heart of the city with skyline views.',
        amenities: ['Free WiFi', 'Gym', 'Conference Rooms', 'Rooftop Bar'],
        images: [
          'https://picsum.photos/seed/hotel2/600/400',
          'https://picsum.photos/seed/hotel2a/600/400',
        ],
        rating: 4.5,
        isPopular: false,
        isNew: true,
        avgPrice: 220.0,
        basePrice: 200.0,
        taxRate: 0.1,
        seoTags: ['city', 'business', 'modern'],
        availableRooms: 8,
        tags: ['New Opening', 'Skyline View'],
      ),
    ]);

    _isLoading = false;
    _hasMore = false;
    notifyListeners();
  }

  /// Fetch hotels; paginated via internal _lastDoc cursor.
  Future<void> fetchHotels({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _lastDoc = null;
      _hasMore = true;
      _hotels.clear();
      notifyListeners();
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _hotelService.getHotelsPaginated(
        startAfter: _lastDoc,
        limit: _pageSize,
        searchQuery: _search.isNotEmpty ? _search : null,
      );

      if (snap.docs.isNotEmpty) {
        for (final d in snap.docs) {
          final data = d.data();
          final model = HotelModel.fromMap(data, id: d.id);
          // avoid duplicates if refresh was partial
          if (!_hotels.any((h) => h.id == model.id)) _hotels.add(model);
        }
        _lastDoc = snap.docs.last;
      }

      if (snap.docs.length < _pageSize) _hasMore = false;
    } catch (e) {
      debugPrint('fetchHotels error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  
  /// Load next page
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    await fetchHotels(refresh: false);
  }

  /// Debounced search trigger can be done in UI; here we simply apply and refresh.
  Future<void> searchHotels(String query) async {
    _search = query.trim();
    // refresh results to apply search
    _lastDoc = null;
    _hasMore = true;
    _hotels.clear();
    notifyListeners();
    await fetchHotels(refresh: true);
  }

  Future<List<RoomModel>> getRoomsByHotel(String hotelId, {bool forceRefresh = false}) async {
    if(!forceRefresh && _roomCache.containsKey(hotelId)) {
      return _roomCache[hotelId]!;
    }

    _isLoading = true;
    notifyListeners();

    final rooms = await _hotelService.getRoomsByHotel(hotelId);
    _roomCache[hotelId] = rooms;

    _isLoading = false;
    notifyListeners();
    return rooms;
  }

  List<HotelModel> get filteredHotels {
    return _hotels.where((hotel) {
      // Add your filter logic here

      return true;
    }).toList();
  }

  Future<void> prefetchHotelDetails(String hotelId) async {
    try {
      // This warms Firestore cache for that doc; the service returns model so UI can get it quickly.
      await _hotelService.getHotelById(hotelId);
    } catch (e) {
      debugPrint('prefetchHotelDetails error: $e');
    }
  }

  Future<void> bulkDeleteHotels(List<String> hotelIds) async {
    for (final id in hotelIds) {
      await _hotelService.deleteHotel(id);
    }
    _hotels.removeWhere((h) => hotelIds.contains(h.id));
    notifyListeners();
  }

  Future<void> approveHotel(String hotelId) async {
    final idx = _hotels.indexWhere((h) => h.id == hotelId);
    if (idx == -1) return;
    final h = _hotels[idx];
    final updated = HotelModel(
      id: h.id,
      name: h.name,
      address: h.address,
      coordinates: h.coordinates,
      description: h.description,
      amenities: h.amenities,
      images: h.images,
      rating: h.rating,
      isPopular: h.isPopular,
      isNew: false,
      avgPrice: h.avgPrice,
      basePrice: h.basePrice,
      taxRate: h.taxRate,
      seoTags: h.seoTags,
      availableRooms: h.availableRooms,
      tags: h.tags,
    );
    await _hotelService.updateHotel(updated);
    _hotels[idx] = updated;
    notifyListeners();
  }
}