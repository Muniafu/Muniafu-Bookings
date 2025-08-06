import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/room.dart';
import 'booking_screen.dart';

class RoomDetailsScreen extends StatefulWidget {
  final Room room;

  const RoomDetailsScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _checkIn = picked.start;
        _checkOut = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final room = widget.room;
    final hasMultipleImages = room.images.isNotEmpty && room.images.length > 1;
    const defaultImage = 'assets/images/room_sample.jpg';

    return Scaffold(
      appBar: AppBar(
        title: Text(room.name),
        backgroundColor: colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel with indicators
            _buildImageSection(room, hasMultipleImages, defaultImage),
            const SizedBox(height: 20),
            
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          room.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$${room.pricePerNight.toStringAsFixed(2)}/night',
                        style: TextStyle(
                          fontSize: 18,
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Availability badge
                  _buildAvailabilityBadge(room),
                  const SizedBox(height: 20),
                  
                  // Date selection
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    title: Text(_checkIn != null && _checkOut != null
                        ? '${DateFormat.yMMMd().format(_checkIn!)} - ${DateFormat.yMMMd().format(_checkOut!)}'
                        : 'Select Check-in & Check-out'),
                    trailing: const Icon(Icons.edit),
                    onTap: _selectDateRange,
                  ),
                  
                  // Guests selection
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text('Guests: $_guests'),
                    trailing: DropdownButton<int>(
                      value: _guests,
                      items: List.generate(5, (i) => i + 1)
                          .map((val) => DropdownMenuItem(value: val, child: Text('$val')))
                          .toList(),
                      onChanged: (val) => setState(() => _guests = val!),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Amenities section
                  if (room.amenities.isNotEmpty) ...[
                    const Text(
                      "Amenities:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: room.amenities
                          .map((amenity) => _buildAmenityChip(amenity))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  
                  // Description
                  const Text(
                    "Description:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.description ?? 
                    "This ${room.name} offers premium comfort with luxurious bedding and modern furnishings. Perfect for both business and leisure travelers.",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  
                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: room.isAvailable && _checkIn != null && _checkOut != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingScreen(
                                    room: room,
                                    checkIn: _checkIn!,
                                    checkOut: _checkOut!,
                                    guests: _guests,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: const Text(
                        "Book Now",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Room room, bool hasMultipleImages, String defaultImage) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Image carousel
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: room.images.isNotEmpty ? room.images.length : 1,
            onPageChanged: (index) => setState(() => _currentImageIndex = index),
            itemBuilder: (_, index) {
              final image = room.images.isNotEmpty 
                  ? room.images[index]
                  : defaultImage;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: image.startsWith('http')
                      ? Image.network(image, fit: BoxFit.cover)
                      : Image.asset(image, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        
        // Image indicators
        if (hasMultipleImages) ...[
          Positioned(
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                room.images.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAvailabilityBadge(Room room) {
    return Chip(
      backgroundColor: room.isAvailable
          ? Colors.green[100]
          : Colors.red[100],
      label: Text(
        room.isAvailable ? 'Available Now' : 'Currently Unavailable',
        style: TextStyle(
          color: room.isAvailable ? Colors.green[800] : Colors.red[800],
        ),
      ),
      avatar: Icon(
        room.isAvailable ? Icons.check_circle : Icons.block,
        color: room.isAvailable ? Colors.green[800] : Colors.red[800],
        size: 18,
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    final icon = _getAmenityIcon(amenity);
    
    return Chip(
      avatar: icon != null ? Icon(icon, size: 18) : null,
      label: Text(amenity),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  IconData? _getAmenityIcon(String amenity) {
    final lowerAmenity = amenity.toLowerCase();
    
    if (lowerAmenity.contains('wifi')) return Icons.wifi;
    if (lowerAmenity.contains('breakfast')) return Icons.restaurant;
    if (lowerAmenity.contains('bed')) return Icons.king_bed;
    if (lowerAmenity.contains('view')) return Icons.visibility;
    if (lowerAmenity.contains('ac') || lowerAmenity.contains('air')) return Icons.ac_unit;
    if (lowerAmenity.contains('tv')) return Icons.tv;
    if (lowerAmenity.contains('pool')) return Icons.pool;
    if (lowerAmenity.contains('gym')) return Icons.fitness_center;
    return null;
  }
}