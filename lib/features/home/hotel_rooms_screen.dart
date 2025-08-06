import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/hotel.dart';
import '../../data/models/room.dart';
import '../../providers/room_provider.dart';
import 'room_details_screen.dart';
import 'booking_screen.dart';

class HotelRoomsScreen extends StatefulWidget {
  final Hotel? hotel;
  final String? destination;
  final String? searchQuery;

  const HotelRoomsScreen({
    Key? key,
    this.hotel,
    this.destination,
    this.searchQuery,
  }) : super(key: key);

  @override
  State<HotelRoomsScreen> createState() => _HotelRoomsScreenState();
}

class _HotelRoomsScreenState extends State<HotelRoomsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.hotel != null) {
      Provider.of<RoomProvider>(context, listen: false)
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
      body: widget.hotel != null ? _buildHotelRoomsContent() : _buildSampleRoomsContent(),
    );
  }

  Widget _buildAppBarTitle() {
    if (widget.hotel != null) {
      return Text('${widget.hotel!.name} Rooms');
    } else if (widget.destination != null) {
      return Text('Rooms in ${widget.destination!}');
    } else if (widget.searchQuery != null) {
      return Text('Results for "${widget.searchQuery!}"');
    }
    return const Text('Available Rooms');
  }

  Widget _buildHotelRoomsContent() {
    return Consumer<RoomProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.rooms.isEmpty) {
          return const Center(child: Text('No rooms available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.rooms.length,
          itemBuilder: (_, index) => _buildRoomCard(provider.rooms[index]),
        );
      },
    );
  }

  Widget _buildSampleRoomsContent() {
    final List<Room> sampleRooms = [
      Room(
        id: '1',
        hotelId: 'sample',
        type: 'Deluxe Room',
        name: 'Deluxe Room',
        pricePerNight: 199.0,
        capacity: 2,
        images: ['https://example.com/room1.jpg'],
        amenities: ['WiFi', 'TV', 'AC'],
        isAvailable: true,
        description: 'Sea view, Free breakfast, 35 sqm',
      ),
      Room(
        id: '2',
        hotelId: 'sample',
        type: 'Executive Suite',
        name: 'Executive Suite',
        pricePerNight: 299.0,
        capacity: 2,
        images: ['https://example.com/room2.jpg'],
        amenities: ['WiFi', 'TV', 'AC', 'Minibar'],
        isAvailable: true,
        description: 'City view, Lounge access, 50 sqm',
      ),
      Room(
        id: '3',
        hotelId: 'sample',
        type: 'Family Room',
        name: 'Family Room',
        pricePerNight: 349.0,
        capacity: 4,
        images: ['https://example.com/room3.jpg'],
        amenities: ['WiFi', 'TV', 'AC', 'Kitchenette'],
        isAvailable: true,
        description: '2 bedrooms, Kitchenette, 60 sqm',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sampleRooms.length,
      itemBuilder: (_, index) => _buildRoomCard(sampleRooms[index]),
    );
  }

  Widget _buildRoomCard(Room room) {
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
              // Room image or icon
              room.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        room.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getRoomIcon(room.type),
                            size: 32,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getRoomIcon(room.type),
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
                      room.type,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (room.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        room.description!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          room.formattedPrice,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        _buildAvailabilityIndicator(room),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _bookRoom(room),
                          child: const Text("Book"),
                        ),
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

  Widget _buildAvailabilityIndicator(Room room) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          room.isAvailable ? Icons.check_circle : Icons.cancel,
          color: room.isAvailable ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          room.isAvailable ? 'Available' : 'Booked',
          style: TextStyle(
            color: room.isAvailable ? Colors.green : Colors.red,
            fontSize: 12,
          ),
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
    final DateTime now = DateTime.now();
    final DateTime checkIn = now.add(const Duration(days: 1));
    final DateTime checkOut = now.add(const Duration(days: 2));
    const int guests = 1;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          room: room,
          checkIn: checkIn,
          checkOut: checkOut,
          guests: guests,
        ),
      ),
    );
  }
}