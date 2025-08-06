import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../features/home/hotel_rooms_screen.dart';
import '../../data/models/hotel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guests = 1;
  int _rooms = 1;
  bool _showSearchResults = false;
  final List<String> _popularLocations = [
    'New York',
    'Paris',
    'Tokyo',
    'London',
    'Dubai'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<HotelProvider>(context, listen: false).loadHotels();
    });
  }

  Future<void> _selectDate({required bool isCheckIn}) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
            _checkOutDate = null;
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  void _incrementGuests() => setState(() => _guests++);
  void _decrementGuests() => setState(() => _guests > 1 ? _guests-- : _guests);

  void _incrementRooms() => setState(() => _rooms++);
  void _decrementRooms() => setState(() => _rooms > 1 ? _rooms-- : _rooms);

  void _performSearch() {
    if (_searchController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a search term")),
      );
      return;
    }
    Provider.of<HotelProvider>(context, listen: false)
        .searchHotels(_searchController.text.trim());
    setState(() => _showSearchResults = true);
  }

  void _showAdvancedSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildAdvancedSearch(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotelProvider = Provider.of<HotelProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Hotels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showAdvancedSearch,
            tooltip: 'Advanced Search',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by hotel name...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
        ),
      ),
      body: _showSearchResults
          ? _buildSearchResults(hotelProvider)
          : _buildPopularDestinations(),
    );
  }

  Widget _buildSearchResults(HotelProvider hotelProvider) {
    return hotelProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : hotelProvider.hotels.isEmpty
            ? const Center(child: Text('No hotels found'))
            : ListView.builder(
                itemCount: hotelProvider.hotels.length,
                itemBuilder: (context, index) {
                  final hotel = hotelProvider.hotels[index];
                  return HotelCard(hotel: hotel);
                },
              );
  }

  Widget _buildPopularDestinations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Popular Destinations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _popularLocations.length,
            itemBuilder: (context, index) {
              final location = _popularLocations[index];
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(location),
                onTap: () {
                  _searchController.text = location;
                  _performSearch();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSearch() {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: "Location",
              hintText: "Enter city or country",
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text("Check-in Date"),
            subtitle: Text(_checkInDate != null
                ? dateFormat.format(_checkInDate!)
                : "Select date"),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(isCheckIn: true),
            ),
          ),
          ListTile(
            title: const Text("Check-out Date"),
            subtitle: Text(_checkOutDate != null
                ? dateFormat.format(_checkOutDate!)
                : "Select date"),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(isCheckIn: false),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Guests", style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  IconButton(
                    onPressed: _decrementGuests,
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$_guests', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    onPressed: _incrementGuests,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Rooms", style: TextStyle(fontSize: 16)),
              Row(
                children: [
                  IconButton(
                    onPressed: _decrementRooms,
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$_rooms', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    onPressed: _incrementRooms,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text("Search Hotels"),
            onPressed: () {
              Navigator.pop(context);
              _performSearch();
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class HotelCard extends StatelessWidget {
  final Hotel hotel;
  const HotelCard({Key? key, required this.hotel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: hotel.images.isNotEmpty
            ? Image.network(
                hotel.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.hotel, size: 60),
        title: Text(hotel.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hotel.location),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${hotel.formattedRating}'),
                const Spacer(),
                Text(hotel.formattedPrice),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HotelRoomsScreen(hotel: hotel),
            ),
          );
        },
      ),
    );
  }
}