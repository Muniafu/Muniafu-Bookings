import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _locationController = TextEditingController();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _guests = 1;
  int _rooms = 1;
  List<String> _searchResults = [];
  final List<String> _dummyHotels = [
    'Hotel Paradise',
    'Ocean View Resort',
    'Mountain Retreat',
    'City Lights Hotel',
    'Cozy Star Inn',
    'Hot Water Springs',
  ];

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
    if (_locationController.text.isEmpty || _checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields before searching.")),
      );
      return;
    }

    // Implement actual search logic here
    print('Searching hotels in ${_locationController.text} '
        'from $_checkInDate to $_checkOutDate '
        'for $_guests guests and $_rooms rooms');
  }

  void _searchLocations(String query) {
    setState(() {
      _searchResults = query.isEmpty
          ? []
          : _dummyHotels
              .where((hotel) => hotel.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text("Search Hotels")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: "Location/Hotel",
                hintText: "Enter city or hotel name",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _searchLocations,
            ),
            if (_searchResults.isNotEmpty)
              ..._searchResults.map((hotel) => ListTile(
                    leading: const Icon(Icons.hotel),
                    title: Text(hotel),
                    onTap: () {
                      setState(() {
                        _locationController.text = hotel;
                        _searchResults.clear();
                      });
                    },
                  )).toList(),
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
              onPressed: _performSearch,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}