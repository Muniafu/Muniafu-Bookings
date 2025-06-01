import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/hotel.dart';
import '../../data/models/room.dart';
import '../.././providers/hotel_provider.dart';
import 'room_details_screen.dart';
import 'booking_screen.dart';

class HotelRoomsScreen extends StatefulWidget {
  final Hotel? hotel;
  final String? destination;
  final String? searchQuery;

  const HotelRoomsScreen({
    super.key,
    this.hotel,
    this.destination,
    this.searchQuery,
  });

  @override
  State<HotelRoomsScreen> createState() => _HotelRoomsScreenState();
}

class _HotelRoomsScreenState extends State<HotelRoomsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.hotel != null) {
      // Remove unused provider variable
      Provider.of<HotelProvider>(context, listen: false)
          .loadRooms(widget.hotel!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildAppBarTitle() {
    if (widget.hotel != null) {
      return Text(widget.hotel!.name);
    } else if (widget.destination != null) {
      return Text('Rooms in ${widget.destination!}');
    } else if (widget.searchQuery != null) {
      return Text('Results for "${widget.searchQuery!}"');
    }
    return const Text('Available Rooms');
  }

  Widget _buildBody() {
    if (widget.hotel != null) {
      return _buildHotelRoomsContent();
    } else {
      return _buildSampleRoomsContent();
    }
  }

  Widget _buildHotelRoomsContent() {
    // Remove unused provider variable, use Consumer directly
    return Consumer<HotelProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        if (provider.rooms.isEmpty) {
          return const Center(child: Text('No rooms available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.rooms.length,
          itemBuilder: (_, i) => _buildRoomCard(provider.rooms[i]),
        );
      },
    );
  }

  Widget _buildSampleRoomsContent() {
    // Sample room data
    final List<Map<String, dynamic>> rooms = [
      {
        'type': 'Deluxe Room',
        'description': 'Sea view, Free breakfast, 35 sqm',
        'icon': Icons.king_bed,
        'price': 199.0,
      },
      {
        'type': 'Executive Suite',
        'description': 'City view, Lounge access, 50 sqm',
        'icon': Icons.business,
        'price': 299.0,
      },
      {
        'type': 'Family Room',
        'description': '2 bedrooms, Kitchenette, 60 sqm',
        'icon': Icons.family_restroom,
        'price': 349.0,
      },
      {
        'type': 'Standard Room',
        'description': 'Garden view, 25 sqm',
        'icon': Icons.single_bed,
        'price': 149.0,
      },
      {
        'type': 'Presidential Suite',
        'description': 'Panoramic views, Butler service, 100 sqm',
        'icon': Icons.villa,
        'price': 599.0,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      itemBuilder: (context, index) => _buildRoomCard(
        Room(
          id: 'sample-$index',
          hotelId: 'sample-hotel',
          type: rooms[index]['type'] as String,
          name: rooms[index]['type'] as String,
          pricePerNight: rooms[index]['price'] as double,
          capacity: 2,
          images: [],
          amenities: [],
          isAvailable: true,
          description: rooms[index]['description'] as String,
        ),
        icon: rooms[index]['icon'] as IconData,
      ),
    );
  }

  Widget _buildRoomCard(Room room, {IconData? icon}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToRoomDetails(room),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room icon or image
              if (room.images.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    room.images.first,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    // Replace withOpacity with colorScheme.primaryContainer
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon ?? _getRoomIcon(room.type),
                    size: 32,
                    color: colorScheme.primary,
                  ),
                ),
              
              const SizedBox(width: 16),
              
              // Room details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (room.description != null) Text(
                      room.description!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${room.pricePerNight.toStringAsFixed(0)}/night',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        _buildActionButtons(room),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Room room) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => _navigateToRoomDetails(room),
          child: const Text("Details"),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _bookRoom(room),
          child: const Text("Book"),
        ),
      ],
    );
  }

  IconData _getRoomIcon(String type) {
    switch (type.toLowerCase()) {
      case 'deluxe':
        return Icons.king_bed;
      case 'executive':
      case 'suite':
        return Icons.business;
      case 'family':
        return Icons.family_restroom;
      case 'presidential':
        return Icons.villa;
      default:
        return Icons.hotel;
    }
  }

  void _navigateToRoomDetails(Room room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomDetailsScreen(room: room),
      ),
    );
  }

  void _bookRoom(Room room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Fix the BookingScreen constructor to accept room parameter
        builder: (_) => BookingScreen(room: room),
      ),
    );
  }
}