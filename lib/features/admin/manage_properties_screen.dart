import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hotel_provider.dart';
import '../../models/hotel_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ManagePropertiesScreen extends StatefulWidget {
  const ManagePropertiesScreen({super.key});

  @override
  State<ManagePropertiesScreen> createState() => _ManagePropertiesScreenState();
}

class _ManagePropertiesScreenState extends State<ManagePropertiesScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _selectedSort = 'Name';
  final Set<String> _selectedHotels = {}; // Bulk actions
  final int _itemsPerPage = 10;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HotelProvider>(context);

    // Apply search + filters
    List<HotelModel> filteredHotels = provider.hotels.where((hotel) {
      final matchesSearch = hotel.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          hotel.address.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Popular' && hotel.isPopular) ||
          (_selectedFilter == 'New' && hotel.isNew);
      return matchesSearch && matchesFilter;
    }).toList();

    // Sorting
    filteredHotels.sort((a, b) {
      switch (_selectedSort) {
        case 'Price':
          return a.avgPrice.compareTo(b.avgPrice);
        case 'Rating':
          return b.rating.compareTo(a.rating);
        default:
          return a.name.compareTo(b.name);
      }
    });

    // Pagination
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, filteredHotels.length);
    final paginatedHotels = filteredHotels.sublist(startIndex, endIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Properties"),
        actions: [
          if (_selectedHotels.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                provider.bulkDeleteHotels(_selectedHotels.toList());
                setState(() => _selectedHotels.clear());
              },
            ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/admin/add-property');
        },
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async => await provider.fetchHotels(refresh: true),
                    child: ListView.builder(
                      itemCount: paginatedHotels.length + 1,
                      itemBuilder: (context, index) {
                        if (index == paginatedHotels.length) {
                          return _buildPaginationControls(filteredHotels.length);
                        }
                        final hotel = paginatedHotels[index];
                        return _buildHotelCard(hotel);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: "Search by name or location",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (val) => setState(() => _searchQuery = val),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: ['All', 'Popular', 'New'].map((filter) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              onSelected: (_) => setState(() => _selectedFilter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHotelCard(HotelModel hotel) {
    final isSelected = _selectedHotels.contains(hotel.id);
    return Dismissible(
      key: Key(hotel.id),
      background: Container(color: Colors.red, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: const Icon(Icons.delete, color: Colors.white)),
      secondaryBackground: Container(color: Colors.green, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.check, color: Colors.white)),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Delete
          return await _confirmDelete(hotel);
        } else {
          // Approve
          Provider.of<HotelProvider>(context, listen: false).approveHotel(hotel.id);
          return false;
        }
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        child: InkWell(
          onLongPress: () {
            setState(() {
              if (isSelected) {
                _selectedHotels.remove(hotel.id);
              } else {
                _selectedHotels.add(hotel.id);
              }
            });
          },
          onTap: () => Navigator.pushNamed(context, '/admin/edit-property', arguments: hotel),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageCarousel(hotel.images),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        hotel.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildStatusBadge(hotel),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    _buildStarRating(hotel.rating),
                    const Spacer(),
                    Text("\$${hotel.avgPrice.toStringAsFixed(2)}/night"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(hotel.address, style: const TextStyle(color: Colors.grey)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    return SizedBox(
      height: 160,
      child: PageView(
        children: images.map((url) {
          return CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (context, _) => Container(color: Colors.grey[300]),
            errorWidget: (_, __, ___) => const Icon(Icons.error),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 18);
      }),
    );
  }

  Widget _buildStatusBadge(HotelModel hotel) {
    String status = hotel.isNew ? 'New' : (hotel.isPopular ? 'Popular' : '');
    Color color = hotel.isNew ? Colors.blue : (hotel.isPopular ? Colors.orange : Colors.grey);
    return status.isEmpty
        ? const SizedBox()
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
          );
  }

  Widget _buildPaginationControls(int totalItems) {
    final totalPages = (totalItems / _itemsPerPage).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
        ),
        Text("Page ${_currentPage + 1} of $totalPages"),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
        ),
      ],
    );
  }

  Future<bool> _confirmDelete(HotelModel hotel) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Property"),
            content: Text("Are you sure you want to delete '${hotel.name}'?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
            ],
          ),
        ) ??
        false;
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sort By"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Name', 'Price', 'Rating'].map((sortOption) {
            return RadioListTile<String>(
              title: Text(sortOption),
              value: sortOption,
              groupValue: _selectedSort,
              onChanged: (val) {
                setState(() => _selectedSort = val!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}