import 'package:flutter/material.dart';

// Search hotels based on user input
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  final List<String> _dummyHotels = [
    'Hotel Paradise',
    'Ocean View Resort',
    'Mountain Retreat',
    'City Lights Hotel',
    'Cozy Star Inn',
    'Hot Water Springs',
  ];

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _dummyHotels
            .where((hotel) => hotel.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Hotels'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                hintText: 'Enter hotel name or location',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _performSearch,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'No results found. Try searching for a hotel.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.hotel),
                          title: Text(_searchResults[index]),
                          onTap: () {
                            // Navigate to hotel details page
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
